import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/crypto_currency.dart';
import '../models/game_state.dart';
import '../screens/crypto_detail_page.dart';

class CryptoTile extends StatefulWidget {
  final CryptoCurrency crypto;
  final GameState gameState;
  final VoidCallback onTap;

  const CryptoTile({
    super.key,
    required this.crypto,
    required this.gameState,
    required this.onTap,
  });

  @override
  State<CryptoTile> createState() => _CryptoTileState();
}

class _CryptoTileState extends State<CryptoTile>
    with TickerProviderStateMixin {
  late AnimationController _priceAnimController;
  late AnimationController _holdingAnimController;
  late AnimationController _pressAnimController;
  
  late Animation<Color?> _priceColorAnimation;
  late Animation<double> _holdingScaleAnimation;
  late Animation<double> _pressScaleAnimation;
  
  double _lastPrice = 0.0;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _lastPrice = widget.crypto.price;
    
    _priceAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _holdingAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pressAnimController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _priceColorAnimation = ColorTween(
      begin: Colors.white,
      end: widget.crypto.isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D),
    ).animate(CurvedAnimation(
      parent: _priceAnimController,
      curve: Curves.easeInOut,
    ));
    
    _holdingScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _holdingAnimController,
      curve: Curves.elasticOut,
    ));
    
    _pressScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressAnimController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _priceAnimController.dispose();
    _holdingAnimController.dispose();
    _pressAnimController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CryptoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Анимация изменения цены
    if (widget.crypto.price != _lastPrice) {
      _priceAnimController.forward().then((_) {
        _priceAnimController.reverse();
      });
      _lastPrice = widget.crypto.price;
    }
    
    // Анимация изменения холдинга
    if (widget.crypto.holding != oldWidget.crypto.holding && widget.crypto.holding > 0) {
      _holdingAnimController.forward().then((_) {
        _holdingAnimController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_priceAnimController, _holdingAnimController, _pressAnimController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pressScaleAnimation.value,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            color: const Color(0xFF1E2329),
            elevation: _isPressed ? 8 : 2,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _openDetailPage(context);
              },
              onLongPress: () {
                HapticFeedback.mediumImpact();
                widget.onTap();
              },
              onTapDown: (_) {
                setState(() => _isPressed = true);
                _pressAnimController.forward();
              },
              onTapUp: (_) {
                setState(() => _isPressed = false);
                _pressAnimController.reverse();
              },
              onTapCancel: () {
                setState(() => _isPressed = false);
                _pressAnimController.reverse();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Аватар криптовалюты
                    _buildCryptoAvatar(),
                    const SizedBox(width: 12),
                    
                    // Информация о криптовалюте
                    Expanded(child: _buildCryptoInfo()),
                    
                    // Цена и изменение
                    _buildPriceInfo(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCryptoAvatar() {
    return Stack(
      children: [
        // Основной аватар
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.crypto.isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D),
                (widget.crypto.isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D)).withOpacity(0.7),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (widget.crypto.isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D)).withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.crypto.symbol.length > 4 ? widget.crypto.symbol.substring(0, 4) : widget.crypto.symbol,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ),
        
        // Индикатор холдинга
        if (widget.crypto.holding > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Transform.scale(
              scale: _holdingScaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0B90B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.black,
                  size: 12,
                ),
              ),
            ),
          ),
        
        // Индикатор тренда
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: widget.crypto.isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.crypto.isPositive ? Icons.trending_up : Icons.trending_down,
              color: Colors.white,
              size: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCryptoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Название с холдингом
        Row(
          children: [
            Expanded(
              child: Text(
                widget.crypto.symbol,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.crypto.holding > 0) ...[
              const SizedBox(width: 4),
              Transform.scale(
                scale: _holdingScaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0B90B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.crypto.holding >= 1000
                        ? '${(widget.crypto.holding / 1000).toStringAsFixed(1)}K'
                        : widget.crypto.holding.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        
        // Полное название
        Text(
          widget.crypto.name,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        
        // Дополнительная информация
        if (widget.crypto.holding > 0) ...[
          const SizedBox(height: 2),
          Text(
            'Стоимость: \$${(widget.crypto.holding * widget.crypto.price).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF02C076),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Цена с анимацией
        AnimatedBuilder(
          animation: _priceColorAnimation,
          builder: (context, child) {
            return Text(
              '\$${_formatPrice(widget.crypto.price)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _priceColorAnimation.value ?? Colors.white,
              ),
            );
          },
        ),
        const SizedBox(height: 2),
        
        // Изменение в процентах
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: (widget.crypto.isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D)).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.crypto.isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: widget.crypto.isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D),
                size: 16,
              ),
              Text(
                '${widget.crypto.changePercent.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  color: widget.crypto.isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Мини-график или дополнительная информация
        const SizedBox(height: 2),
        if (widget.crypto.priceHistory.length > 5)
          SizedBox(
            width: 60,
            height: 20,
            child: CustomPaint(
              painter: MiniChartPainter(
                prices: widget.crypto.priceHistory.take(20).toList(),
                color: widget.crypto.isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D),
              ),
            ),
          )
        else
          Text(
            'Новая',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    } else if (price >= 1) {
      return price.toStringAsFixed(2);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(6);
    }
  }

  void _openDetailPage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CryptoDetailPage(
          crypto: widget.crypto,
          gameState: widget.gameState,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class MiniChartPainter extends CustomPainter {
  final List<double> prices;
  final Color color;

  MiniChartPainter({required this.prices, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    if (priceRange == 0) return;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < prices.length; i++) {
      final x = (i / (prices.length - 1)) * size.width;
      final y = size.height - ((prices[i] - minPrice) / priceRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Замыкаем путь для заливки
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Рисуем заливку
    canvas.drawPath(fillPath, fillPaint);

    // Рисуем линию
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}