import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/game_notification.dart';
import '../widgets/notification_widget.dart';

class NotificationSystem {
  static NotificationSystem? _instance;
  static NotificationSystem get instance {
    _instance ??= NotificationSystem._();
    return _instance!;
  }
  
  NotificationSystem._();
  
  OverlayEntry? _currentNotification;
  final List<GameNotification> _notificationQueue = [];
  Timer? _queueTimer;
  
  /// Показать уведомление
  void showNotification(BuildContext context, GameNotification notification) {
    if (!context.mounted) return;
    _notificationQueue.add(notification);
    _processQueue(context);
  }
  
  /// Показать достижение
  void showAchievement(BuildContext context, {
    required String title,
    required String description,
    required int reputationReward,
    VoidCallback? onTap,
  }) {
    showNotification(context, GameNotification.achievement(
      title: title,
      description: description,
      reputationReward: reputationReward,
      onTap: onTap,
    ));
  }
  
  /// Показать повышение уровня
  void showLevelUp(BuildContext context, {
    required int newLevel,
    required int reputationGained,
    VoidCallback? onTap,
  }) {
    showNotification(context, GameNotification.levelUp(
      newLevel: newLevel,
      reputationGained: reputationGained,
      onTap: onTap,
    ));
  }
  
  /// Показать торговую сделку
  void showTrade(BuildContext context, {
    required String action,
    required String crypto,
    required double amount,
    required double price,
    VoidCallback? onTap,
  }) {
    showNotification(context, GameNotification.trade(
      action: action,
      crypto: crypto,
      amount: amount,
      price: price,
      onTap: onTap,
    ));
  }
  
  /// Показать событие
  void showEvent(BuildContext context, {
    required String eventTitle,
    required String description,
    VoidCallback? onTap,
  }) {
    showNotification(context, GameNotification.event(
      eventTitle: eventTitle,
      description: description,
      onTap: onTap,
    ));
  }
  
  /// Показать доход от майнинга
  void showMining(BuildContext context, {
    required double earnings,
    VoidCallback? onTap,
  }) {
    showNotification(context, GameNotification.mining(
      earnings: earnings,
      onTap: onTap,
    ));
  }
  
  /// Показать предупреждение
  void showWarning(BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    showNotification(context, GameNotification.warning(
      title: title,
      message: message,
      onTap: onTap,
    ));
  }
  
  /// Показать информационное сообщение
  void showInfo(BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    showNotification(context, GameNotification.info(
      title: title,
      message: message,
      onTap: onTap,
    ));
  }
  
  void _processQueue(BuildContext context) {
    if (_currentNotification != null || _notificationQueue.isEmpty || !context.mounted) return;
    
    final notification = _notificationQueue.removeAt(0);
    _currentNotification = _createNotificationOverlay(context, notification);
    
    if (context.mounted) {
      Overlay.of(context).insert(_currentNotification!);
      HapticFeedback.lightImpact();
    }
    
    // Автоматически скрыть через время
    Timer(Duration(seconds: notification.duration), () {
      _hideCurrentNotification();
      // Обработать следующее уведомление через небольшую задержку
      Timer(const Duration(milliseconds: 300), () {
        if (_notificationQueue.isNotEmpty && context.mounted) {
          _processQueue(context);
        }
      });
    });
  }
  
  void _hideCurrentNotification() {
    _currentNotification?.remove();
    _currentNotification = null;
  }
  
  OverlayEntry _createNotificationOverlay(BuildContext context, GameNotification notification) {
    return OverlayEntry(
      builder: (context) => NotificationWidget(
        notification: notification,
        onDismiss: _hideCurrentNotification,
      ),
    );
  }
  
  /// Очистить все уведомления
  void clear() {
    _hideCurrentNotification();
    _notificationQueue.clear();
    _queueTimer?.cancel();
  }
}

/// Расширение для удобства использования
extension NotificationExtensions on BuildContext {
  void showGameNotification(GameNotification notification) {
    NotificationSystem.instance.showNotification(this, notification);
  }

  void showAchievementNotification({
    required String title,
    required String description,
    required int reputationReward,
    VoidCallback? onTap,
  }) {
    NotificationSystem.instance.showAchievement(this,
      title: title,
      description: description,
      reputationReward: reputationReward,
      onTap: onTap,
    );
  }

  void showLevelUpNotification({
    required int newLevel,
    required int reputationGained,
    VoidCallback? onTap,
  }) {
    NotificationSystem.instance.showLevelUp(this,
      newLevel: newLevel,
      reputationGained: reputationGained,
      onTap: onTap,
    );
  }

  void showTradeNotification({
    required String action,
    required String crypto,
    required double amount,
    required double price,
    VoidCallback? onTap,
  }) {
    NotificationSystem.instance.showTrade(this,
      action: action,
      crypto: crypto,
      amount: amount,
      price: price,
      onTap: onTap,
    );
  }

  void showEventNotification({
    required String eventTitle,
    required String description,
    VoidCallback? onTap,
  }) {
    NotificationSystem.instance.showEvent(this,
      eventTitle: eventTitle,
      description: description,
      onTap: onTap,
    );
  }

  void showWarningNotification({
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    NotificationSystem.instance.showWarning(this,
      title: title,
      message: message,
      onTap: onTap,
    );
  }

  void showInfoNotification({
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    NotificationSystem.instance.showInfo(this,
      title: title,
      message: message,
      onTap: onTap,
    );
  }
}