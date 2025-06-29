import 'package:flutter/material.dart';

enum NotificationType {
  achievement,
  levelUp,
  trade,
  event,
  mining,
  warning,
  info,
}

class GameNotification {
  final String title;
  final String message;
  final NotificationType type;
  final IconData icon;
  final Color color;
  final int duration;
  final VoidCallback? onTap;
  final Map<String, dynamic>? data;

  GameNotification({
    required this.title,
    required this.message,
    required this.type,
    this.icon = Icons.info,
    this.color = Colors.blue,
    this.duration = 3,
    this.onTap,
    this.data,
  });

  factory GameNotification.achievement({
    required String title,
    required String description,
    required int reputationReward,
    VoidCallback? onTap,
  }) {
    return GameNotification(
      title: '🏆 Достижение получено!',
      message: '$title\n+$reputationReward репутации',
      type: NotificationType.achievement,
      icon: Icons.emoji_events,
      color: const Color(0xFFF0B90B),
      duration: 4,
      onTap: onTap,
    );
  }

  factory GameNotification.levelUp({
    required int newLevel,
    required int reputationGained,
    VoidCallback? onTap,
  }) {
    return GameNotification(
      title: '🎉 Уровень повышен!',
      message: 'Теперь вы $newLevel уровня!\n+$reputationGained репутации',
      type: NotificationType.levelUp,
      icon: Icons.trending_up,
      color: const Color(0xFF02C076),
      duration: 4,
      onTap: onTap,
    );
  }

  factory GameNotification.trade({
    required String action,
    required String crypto,
    required double amount,
    required double price,
    VoidCallback? onTap,
  }) {
    final isPositive = action == 'buy';
    return GameNotification(
      title: '💰 Сделка выполнена',
      message: '${isPositive ? 'Куплено' : 'Продано'} ${amount.toStringAsFixed(4)} $crypto\nза \$${price.toStringAsFixed(2)}',
      type: NotificationType.trade,
      icon: isPositive ? Icons.trending_up : Icons.trending_down,
      color: isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D),
      duration: 3,
      onTap: onTap,
    );
  }

  factory GameNotification.event({
    required String eventTitle,
    required String description,
    VoidCallback? onTap,
  }) {
    return GameNotification(
      title: '⚡ Новое событие!',
      message: '$eventTitle\n$description',
      type: NotificationType.event,
      icon: Icons.flash_on,
      color: const Color(0xFFF0B90B),
      duration: 4,
      onTap: onTap,
    );
  }

  factory GameNotification.mining({
    required double earnings,
    VoidCallback? onTap,
  }) {
    return GameNotification(
      title: '⛏️ Доход от майнинга',
      message: 'Заработано \$${earnings.toStringAsFixed(2)}',
      type: NotificationType.mining,
      icon: Icons.memory,
      color: const Color(0xFF02C076),
      duration: 2,
      onTap: onTap,
    );
  }

  factory GameNotification.warning({
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    return GameNotification(
      title: title,
      message: message,
      type: NotificationType.warning,
      icon: Icons.warning,
      color: const Color(0xFFF6465D),
      duration: 4,
      onTap: onTap,
    );
  }

  factory GameNotification.info({
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    return GameNotification(
      title: title,
      message: message,
      type: NotificationType.info,
      icon: Icons.info,
      color: Colors.blue,
      duration: 3,
      onTap: onTap,
    );
  }
}