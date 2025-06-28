import 'package:flutter/material.dart';

class TraderStatus {
  final String name;
  final IconData icon;
  final Color color;
  final int minReputation;
  final String description;
  final double tradingBonus;

  const TraderStatus(
    this.name,
    this.icon,
    this.color,
    this.minReputation,
    this.description,
    this.tradingBonus,
  );

  static const List<TraderStatus> statuses = [
    TraderStatus('Новичок', Icons.person, Colors.grey, 0, 'Только начинаете свой путь', 1.0),
    TraderStatus('Стажер', Icons.school, Colors.blue, 100, 'Изучили основы торговли', 1.05),
    TraderStatus('Трейдер', Icons.trending_up, Colors.green, 500, 'Уверенный игрок рынка', 1.1),
    TraderStatus('Профи', Icons.workspace_premium, Colors.orange, 1500, 'Профессиональный трейдер', 1.15),
    TraderStatus('Эксперт', Icons.diamond, Colors.purple, 5000, 'Эксперт финансовых рынков', 1.2),
    TraderStatus('Магнат', Icons.stars, Color(0xFFF0B90B), 15000, 'Финансовый магнат', 1.25),
    TraderStatus('Миллиардер', Icons.emoji_events, Color(0xFFFFD700), 50000, 'Криптомиллиардер', 1.3),
  ];

  static TraderStatus getStatus(int reputation) {
    for (int i = statuses.length - 1; i >= 0; i--) {
      if (reputation >= statuses[i].minReputation) {
        return statuses[i];
      }
    }
    return statuses[0];
  }
}