import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'notification_system.dart';

class AchievementManager {
  static AchievementManager? _instance;
  static AchievementManager get instance {
    _instance ??= AchievementManager._();
    return _instance!;
  }
  
  AchievementManager._();
  
  /// Проверить все достижения для игрока
  void checkAchievements(BuildContext context, GameState gameState) {
    _checkFirstPurchase(context, gameState);
    _checkThousandDollars(context, gameState);
    _checkFirstMiningRig(context, gameState);
    _checkMillionaire(context, gameState);
    _checkFirstLuxury(context, gameState);
    _checkFiveLuxuries(context, gameState);
    _checkTraderDayAchievement(context, gameState);
    _checkHodlerAchievement(context, gameState);
  }
  
  /// Проверить достижение "Первая покупка"
  void _checkFirstPurchase(BuildContext context, GameState gameState) {
    final hasAnyCrypto = gameState.cryptos.any((crypto) => crypto.holding > 0);
    try {
      final achievement = gameState.achievements.firstWhere(
        (a) => a.title == 'Первая покупка',
      );
      
      if (hasAnyCrypto && !achievement.isCompleted) {
        achievement.complete();
        gameState.reputation += achievement.reputationReward;
        
        NotificationSystem.instance.showAchievement(context,
          title: achievement.title,
          description: achievement.description,
          reputationReward: achievement.reputationReward,
        );
      }
    } catch (e) {
      // Достижение не найдено
    }
  }
  
  /// Проверить достижение "Тысячник"
  void _checkThousandDollars(BuildContext context, GameState gameState) {
    try {
      final achievement = gameState.achievements.firstWhere(
        (a) => a.title == 'Тысячник',
      );
      
      if (gameState.balance >= 1000 && !achievement.isCompleted) {
        achievement.complete();
        gameState.reputation += achievement.reputationReward;
        
        NotificationSystem.instance.showAchievement(context,
          title: achievement.title,
          description: achievement.description,
          reputationReward: achievement.reputationReward,
        );
      }
    } catch (e) {
      // Достижение не найдено
    }
  }
  
  /// Проверить достижение "Майнер"
  void _checkFirstMiningRig(BuildContext context, GameState gameState) {
    try {
      final achievement = gameState.achievements.firstWhere(
        (a) => a.title == 'Майнер',
      );
      
      if (gameState.miningRigs.isNotEmpty && !achievement.isCompleted) {
        achievement.complete();
        gameState.reputation += achievement.reputationReward;
        
        NotificationSystem.instance.showAchievement(context,
          title: achievement.title,
          description: achievement.description,
          reputationReward: achievement.reputationReward,
        );
      }
    } catch (e) {
      // Достижение не найдено
    }
  }
  
  /// Проверить достижение "Миллионер"
  void _checkMillionaire(BuildContext context, GameState gameState) {
    try {
      final achievement = gameState.achievements.firstWhere(
        (a) => a.title == 'Миллионер',
      );
      
      if (gameState.balance >= 1000000 && !achievement.isCompleted) {
        achievement.complete();
        gameState.reputation += achievement.reputationReward;
        
        NotificationSystem.instance.showAchievement(context,
          title: achievement.title,
          description: achievement.description,
          reputationReward: achievement.reputationReward,
        );
      }
    } catch (e) {
      // Достижение не найдено
    }
  }
  
  /// Проверить достижение "Модник"
  void _checkFirstLuxury(BuildContext context, GameState gameState) {
    try {
      final achievement = gameState.achievements.firstWhere(
        (a) => a.title == 'Модник',
      );
      
      if (gameState.ownedLuxuryItems.isNotEmpty && !achievement.isCompleted) {
        achievement.complete();
        gameState.reputation += achievement.reputationReward;
        
        NotificationSystem.instance.showAchievement(context,
          title: achievement.title,
          description: achievement.description,
          reputationReward: achievement.reputationReward,
        );
      }
    } catch (e) {
      // Достижение не найдено
    }
  }
  
  /// Проверить достижение "Коллекционер"
  void _checkFiveLuxuries(BuildContext context, GameState gameState) {
    try {
      final achievement = gameState.achievements.firstWhere(
        (a) => a.title == 'Коллекционер',
      );
      
      if (gameState.ownedLuxuryItems.length >= 5 && !achievement.isCompleted) {
        achievement.complete();
        gameState.reputation += achievement.reputationReward;
        
        NotificationSystem.instance.showAchievement(context,
          title: achievement.title,
          description: achievement.description,
          reputationReward: achievement.reputationReward,
        );
      }
    } catch (e) {
      // Достижение не найдено
    }
  }
  
  /// Проверить достижение "Трейдер дня"
  void _checkTraderDayAchievement(BuildContext context, GameState gameState) {
    try {
      final achievement = gameState.achievements.firstWhere(
        (a) => a.title == 'Трейдер дня',
      );
      
      // Здесь должна быть логика подсчета сделок за день
      // Пока упрощенная версия - общее количество сделок
      final totalTrades = gameState.cryptos.fold<int>(
        0, (sum, crypto) => sum + (crypto.holding > 0 ? 1 : 0)
      );
      
      if (totalTrades >= 10 && !achievement.isCompleted) {
        achievement.complete();
        gameState.reputation += achievement.reputationReward;
        
        NotificationSystem.instance.showAchievement(context,
          title: achievement.title,
          description: achievement.description,
          reputationReward: achievement.reputationReward,
        );
      }
    } catch (e) {
      // Достижение не найдено
    }
  }
  
  /// Проверить достижение "Ходлер"
  void _checkHodlerAchievement(BuildContext context, GameState gameState) {
    try {
      final achievement = gameState.achievements.firstWhere(
        (a) => a.title == 'Ходлер',
      );
      
      // Здесь должна быть логика отслеживания времени удержания позиции
      // Пока упрощенная версия - если есть любая позиция
      final hasLongPosition = gameState.cryptos.any((crypto) => crypto.holding > 0);
      
      if (hasLongPosition && !achievement.isCompleted) {
        achievement.complete();
        gameState.reputation += achievement.reputationReward;
        
        NotificationSystem.instance.showAchievement(context,
          title: achievement.title,
          description: achievement.description,
          reputationReward: achievement.reputationReward,
        );
      }
    } catch (e) {
      // Достижение не найдено
    }
  }
  
  /// Проверить повышение уровня
  void checkLevelUp(BuildContext context, GameState gameState, int oldLevel) {
    if (gameState.level > oldLevel) {
      NotificationSystem.instance.showLevelUp(context,
        newLevel: gameState.level,
        reputationGained: 10, // Стандартная награда за уровень
      );
    }
  }
  
  /// Уведомить о торговой сделке
  void notifyTrade(BuildContext context, {
    required String action,
    required String crypto,
    required double amount,
    required double totalPrice,
  }) {
    NotificationSystem.instance.showTrade(context,
      action: action,
      crypto: crypto,
      amount: amount,
      price: totalPrice,
    );
  }
  
  /// Уведомить о покупке предмета роскоши
  void notifyLuxuryPurchase(BuildContext context, {
    required String itemName,
    required int reputationBonus,
  }) {
    NotificationSystem.instance.showInfo(context,
      title: '💎 Покупка совершена!',
      message: 'Куплен $itemName\n+$reputationBonus репутации',
    );
  }
  
  /// Уведомить о доходе от майнинга (пакетно)
  void notifyMiningEarnings(BuildContext context, double totalEarnings) {
    if (totalEarnings > 10) { // Показывать только значительные суммы
      NotificationSystem.instance.showMining(context,
        earnings: totalEarnings,
      );
    }
  }
  
  /// Уведомить о новом событии
  void notifyGameEvent(BuildContext context, {
    required String eventTitle,
    required String description,
  }) {
    NotificationSystem.instance.showEvent(context,
      eventTitle: eventTitle,
      description: description,
    );
  }
}