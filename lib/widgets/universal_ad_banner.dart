import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Универсальный виджет рекламного баннера без overflow
class UniversalAdBanner extends StatelessWidget {
  final String text;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final VoidCallback? onDismiss;
  final bool dismissible;
  final Color? backgroundColor;
  final Color? buttonColor;
  final IconData? icon;

  const UniversalAdBanner({
    super.key,
    required this.text,
    required this.buttonText,
    this.onButtonPressed,
    this.onDismiss,
    this.dismissible = true,
    this.backgroundColor,
    this.buttonColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 40,
        maxHeight: 50, // Уменьшили максимальную высоту
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (backgroundColor ?? const Color(0xFFF0B90B)).withOpacity(0.1),
            (backgroundColor ?? const Color(0xFF02C076)).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (backgroundColor ?? const Color(0xFFF0B90B)).withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Уменьшили отступы
        child: Row(
          children: [
            // Иконка (опционально)
            if (icon != null) ...[
              Icon(
                icon,
                color: backgroundColor ?? const Color(0xFFF0B90B),
                size: 16, // Уменьшили размер иконки
              ),
              const SizedBox(width: 6),
            ],
            
            // Текст
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: backgroundColor ?? const Color(0xFFF0B90B),
                  fontWeight: FontWeight.bold,
                  fontSize: 11, // Уменьшили размер шрифта
                  height: 1.2, // Добавили высоту строки
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // Ограничили одной строкой
              ),
            ),
            
            const SizedBox(width: 6),
            
            // Кнопка действия
            if (onButtonPressed != null)
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onButtonPressed!();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor ?? const Color(0xFFF0B90B),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Уменьшили отступы
                  minimumSize: const Size(60, 28), // Уменьшили минимальный размер
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 9, // Уменьшили размер шрифта кнопки
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            // Кнопка закрытия (опционально)
            if (dismissible && onDismiss != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 14, // Уменьшили размер иконки закрытия
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Фабрика для создания стандартных рекламных баннеров
class AdBannerFactory {
  
  /// Баннер для премиум стратегий
  static Widget premiumStrategies({VoidCallback? onTap, VoidCallback? onDismiss}) {
    return UniversalAdBanner(
      text: '🚀 Премиум',
      buttonText: 'ОТКРЫТЬ',
      icon: Icons.trending_up,
      onButtonPressed: onTap,
      onDismiss: onDismiss,
    );
  }
  
  /// Баннер для статуса/престижа
  static Widget prestigeBanner({VoidCallback? onTap}) {
    return UniversalAdBanner(
      text: '💎 Повышай статус - открывай возможности',
      buttonText: 'ПРЕСТИЖ',
      icon: Icons.diamond,
      backgroundColor: const Color(0xFFF0B90B),
      onButtonPressed: onTap,
      dismissible: false,
    );
  }
  
  /// Баннер для событий
  static Widget eventsBanner({VoidCallback? onTap, VoidCallback? onDismiss}) {
    return UniversalAdBanner(
      text: '🎮 События и награды ждут!',
      buttonText: 'ПОЛУЧИТЬ',
      icon: Icons.event,
      backgroundColor: const Color(0xFF02C076),
      onButtonPressed: onTap,
      onDismiss: onDismiss,
    );
  }
  
  /// Баннер для торговли
  static Widget tradingBanner({VoidCallback? onTap, VoidCallback? onDismiss}) {
    return UniversalAdBanner(
      text: '📈 Продвинутые стратегии торговли',
      buttonText: 'УЗНАТЬ',
      icon: Icons.trending_up,
      backgroundColor: const Color(0xFF02C076),
      onButtonPressed: onTap,
      onDismiss: onDismiss,
    );
  }
  
  /// Баннер для криптовалют
  static Widget cryptoBanner({VoidCallback? onTap, VoidCallback? onDismiss}) {
    return UniversalAdBanner(
      text: '💰 Лучшие криптокошельки 2025',
      buttonText: 'СМОТРЕТЬ',
      icon: Icons.account_balance_wallet,
      onButtonPressed: onTap,
      onDismiss: onDismiss,
    );
  }
  
  /// Интерстициальная реклама (полноэкранная)
  static Widget interstitialAd({
    required String title,
    required String description,
    required String buttonText,
    VoidCallback? onButtonPressed,
    VoidCallback? onDismiss,
  }) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 70), // Уменьшили высоту
      color: const Color(0xFF1E2329),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(6), // Уменьшили отступы
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFF0B90B),
                        fontWeight: FontWeight.bold,
                        fontSize: 12, // Уменьшили размер
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10, // Уменьшили размер
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Ограничили одной строкой
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02C076),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Уменьшили отступы
                  minimumSize: const Size(0, 32), // Уменьшили высоту
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 10, // Уменьшили размер
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 16), // Уменьшили размер
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28), // Уменьшили размер
                ),
            ],
          ),
        ),
      ),
    );
  }
}