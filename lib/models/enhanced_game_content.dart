import 'package:flutter/material.dart';
import 'dart:math';

// Расширенные события игры
class GameEvent {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final EventType type;
  final Map<String, double> cryptoImpact; // symbol -> impact multiplier
  final int duration; // в секундах
  final double probability; // шанс появления
  bool isActive;
  int activeTicks;

  GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.cryptoImpact,
    required this.duration,
    required this.probability,
    this.isActive = false,
    this.activeTicks = 0,
  });

  void activate() {
    isActive = true;
    activeTicks = 0;
  }

  void tick() {
    if (isActive) {
      activeTicks++;
      if (activeTicks >= duration) {
        isActive = false;
        activeTicks = 0;
      }
    }
  }

  static List<GameEvent> getAllEvents() {
    return [
      // Криптособытия
      GameEvent(
        id: 'whale_buy',
        title: '🐋 Кит покупает!',
        description: 'Крупный инвестор массово скупает криптовалюту',
        icon: Icons.trending_up,
        color: const Color(0xFF02C076),
        type: EventType.crypto,
        cryptoImpact: {'BTC': 1.15, 'ETH': 1.10},
        duration: 30,
        probability: 0.15,
      ),
      
      GameEvent(
        id: 'regulatory_news',
        title: '⚖️ Регуляторные новости',
        description: 'Правительство объявило новые правила для криптовалют',
        icon: Icons.gavel,
        color: const Color(0xFFF6465D),
        type: EventType.regulatory,
        cryptoImpact: {'BTC': 0.85, 'ETH': 0.90, 'BNB': 0.80},
        duration: 60,
        probability: 0.08,
      ),

      GameEvent(
        id: 'elon_tweet',
        title: '🚀 Илон Маск твитнул!',
        description: 'Илон Маск написал что-то про криптовалюты',
        icon: Icons.rocket_launch,
        color: const Color(0xFFF0B90B),
        type: EventType.social,
        cryptoImpact: {'DOGE': 1.25, 'BTC': 1.08},
        duration: 20,
        probability: 0.12,
      ),

      GameEvent(
        id: 'tech_update',
        title: '🔧 Техническое обновление',
        description: 'Выпущено важное обновление протокола',
        icon: Icons.build,
        color: const Color(0xFF02C076),
        type: EventType.technical,
        cryptoImpact: {'ETH': 1.12, 'ADA': 1.08, 'SOL': 1.10},
        duration: 45,
        probability: 0.10,
      ),

      GameEvent(
        id: 'market_crash',
        title: '📉 Обвал рынка!',
        description: 'Глобальная распродажа на крипторынке',
        icon: Icons.trending_down,
        color: const Color(0xFFF6465D),
        type: EventType.market,
        cryptoImpact: {
          'BTC': 0.75, 'ETH': 0.80, 'BNB': 0.85, 'ADA': 0.70,
          'SOL': 0.75, 'DOT': 0.80, 'DOGE': 0.60, 'SHIB': 0.50
        },
        duration: 90,
        probability: 0.05,
      ),

      GameEvent(
        id: 'bull_run',
        title: '🚀 Бычий забег!',
        description: 'Весь рынок растет как на дрожжах!',
        icon: Icons.rocket,
        color: const Color(0xFF02C076),
        type: EventType.market,
        cryptoImpact: {
          'BTC': 1.20, 'ETH': 1.25, 'BNB': 1.15, 'ADA': 1.30,
          'SOL': 1.25, 'DOT': 1.20, 'DOGE': 1.40, 'SHIB': 1.50
        },
        duration: 120,
        probability: 0.03,
      ),

      GameEvent(
        id: 'exchange_hack',
        title: '💀 Хак биржи!',
        description: 'Крупная биржа подверглась кибератаке',
        icon: Icons.warning,
        color: const Color(0xFFF6465D),
        type: EventType.security,
        cryptoImpact: {
          'BTC': 0.88, 'ETH': 0.85, 'BNB': 0.70, 'ADA': 0.90,
        },
        duration: 60,
        probability: 0.06,
      ),

      GameEvent(
        id: 'institutional_adoption',
        title: '🏦 Институциональное внедрение',
        description: 'Крупные банки начинают работать с криптовалютами',
        icon: Icons.business,
        color: const Color(0xFF02C076),
        type: EventType.adoption,
        cryptoImpact: {'BTC': 1.18, 'ETH': 1.15, 'BNB': 1.12},
        duration: 180,
        probability: 0.04,
      ),
    ];
  }
}

enum EventType {
  crypto,
  regulatory, 
  social,
  technical,
  market,
  security,
  adoption,
}

// Система квестов и достижений
class Quest {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final QuestType type;
  final Map<String, int> requirements;
  final QuestReward rewards;
  bool isCompleted;
  bool isActive;
  double progress;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.requirements,
    required this.rewards,
    this.isCompleted = false,
    this.isActive = true,
    this.progress = 0.0,
  });

  void updateProgress(Map<String, int> playerStats) {
    if (isCompleted || !isActive) return;

    switch (type) {
      case QuestType.trading:
        if (requirements.containsKey('trades_count')) {
          progress = (playerStats['trades_count'] ?? 0) / requirements['trades_count']!;
        }
        break;
      
      case QuestType.profit:
        if (requirements.containsKey('profit_amount')) {
          progress = (playerStats['total_profit'] ?? 0) / requirements['profit_amount']!;
        }
        break;
      
      case QuestType.mining:
        if (requirements.containsKey('mining_rigs')) {
          progress = (playerStats['mining_rigs_count'] ?? 0) / requirements['mining_rigs']!;
        }
        break;
      
      case QuestType.holding:
        if (requirements.containsKey('hold_duration')) {
          progress = (playerStats['max_hold_time'] ?? 0) / requirements['hold_duration']!;
        }
        break;
    }

    if (progress >= 1.0 && !isCompleted) {
      complete();
    }
  }

  void complete() {
    isCompleted = true;
    progress = 1.0;
  }

  static List<Quest> getAllQuests() {
    return [
      Quest(
        id: 'first_trader',
        title: 'Первые шаги',
        description: 'Совершите 5 сделок',
        icon: Icons.trending_up,
        color: const Color(0xFF02C076),
        type: QuestType.trading,
        requirements: {'trades_count': 5},
        rewards: QuestReward(money: 500, reputation: 50),
      ),
      
      Quest(
        id: 'profit_maker',
        title: 'Делатель прибыли',
        description: 'Заработайте \$1,000 прибыли',
        icon: Icons.attach_money,
        color: const Color(0xFFF0B90B),
        type: QuestType.profit,
        requirements: {'profit_amount': 1000},
        rewards: QuestReward(money: 2000, reputation: 100),
      ),
      
      Quest(
        id: 'mining_master',
        title: 'Мастер майнинга',
        description: 'Купите 3 майнинг-рига',
        icon: Icons.memory,
        color: Colors.purple,
        type: QuestType.mining,
        requirements: {'mining_rigs': 3},
        rewards: QuestReward(money: 1500, reputation: 75),
      ),
      
      Quest(
        id: 'diamond_hands',
        title: 'Алмазные руки',
        description: 'Держите позицию 5 минут',
        icon: Icons.diamond,
        color: Colors.cyan,
        type: QuestType.holding,
        requirements: {'hold_duration': 300}, // 5 минут в секундах
        rewards: QuestReward(money: 800, reputation: 60),
      ),
      
      Quest(
        id: 'day_trader',
        title: 'Дневной трейдер',
        description: 'Совершите 20 сделок за день',
        icon: Icons.access_time,
        color: Colors.orange,
        type: QuestType.trading,
        requirements: {'daily_trades': 20},
        rewards: QuestReward(money: 5000, reputation: 200),
      ),
      
      Quest(
        id: 'whale_hunter',
        title: 'Охотник на китов',
        description: 'Заработайте \$50,000',
        icon: Icons.waves,
        color: Colors.blue,
        type: QuestType.profit,
        requirements: {'profit_amount': 50000},
        rewards: QuestReward(money: 25000, reputation: 500, title: 'Охотник на китов'),
      ),
    ];
  }
}

enum QuestType {
  trading,
  profit,
  mining,
  holding,
}

class QuestReward {
  final int? money;
  final int? reputation;
  final String? title;

  QuestReward({
    this.money,
    this.reputation,
    this.title,
  });
  Map<String, dynamic> toMap() {
    return {
      'money': money ?? 0,
      'reputation': reputation ?? 0,
      'title': title ?? '',
    };
  }
}

// Система турниров
class Tournament {
  final String id;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final TournamentType type;
  final Map<int, TournamentPrize> prizes;
  final List<TournamentParticipant> participants;
  bool isActive;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.prizes,
    required this.participants,
    this.isActive = false,
  });

  bool get isOngoing => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get hasEnded => DateTime.now().isAfter(endTime);

  Duration get timeLeft => endTime.difference(DateTime.now());

  static List<Tournament> getActiveTournaments() {
    final now = DateTime.now();
    return [
      Tournament(
        id: 'weekly_profit',
        name: 'Недельная прибыль',
        description: 'Заработайте больше всех за неделю!',
        startTime: now,
        endTime: now.add(const Duration(days: 7)),
        type: TournamentType.profit,
        prizes: {
          1: TournamentPrize(money: 50000, reputation: 1000, title: 'Король прибыли'),
          2: TournamentPrize(money: 25000, reputation: 500, title: 'Мастер торговли'),
          3: TournamentPrize(money: 10000, reputation: 250, title: 'Умелый трейдер'),
        },
        participants: [],
      ),
      
      Tournament(
        id: 'daily_volume',
        name: 'Дневной объем',
        description: 'Торгуйте на максимальный объем!',
        startTime: now,
        endTime: now.add(const Duration(days: 1)),
        type: TournamentType.volume,
        prizes: {
          1: TournamentPrize(money: 15000, reputation: 300),
          2: TournamentPrize(money: 8000, reputation: 150),
          3: TournamentPrize(money: 4000, reputation: 75),
        },
        participants: [],
      ),
    ];
  }
}

enum TournamentType {
  profit,
  volume,
  accuracy,
}

class TournamentPrize {
  final int money;
  final int reputation;
  final String? title;

  TournamentPrize({
    required this.money,
    required this.reputation,
    this.title,
  });
}

class TournamentParticipant {
  final String playerId;
  final String playerName;
  final double score;
  final int rank;

  TournamentParticipant({
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.rank,
  });
}

// Социальные функции
class SocialFeed {
  final String id;
  final String playerName;
  final String action;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final FeedType type;

  SocialFeed({
    required this.id,
    required this.playerName,
    required this.action,
    required this.data,
    required this.timestamp,
    required this.type,
  });

  String get displayText {
    switch (type) {
      case FeedType.trade:
        return '$playerName ${data['type'] == 'buy' ? 'купил' : 'продал'} ${data['amount']} ${data['crypto']} за \$${data['total']}';
      
      case FeedType.achievement:
        return '$playerName получил достижение "${data['title']}"!';
      
      case FeedType.level_up:
        return '$playerName достиг ${data['level']} уровня!';
      
      case FeedType.tournament:
        return '$playerName занял ${data['place']} место в турнире "${data['tournament']}"!';
      
      default:
        return action;
    }
  }

  static List<SocialFeed> generateFeed() {
    final names = ['CryptoKing', 'MoonLander', 'DiamondHands', 'BullRider', 'Satoshi2024'];
    final cryptos = ['BTC', 'ETH', 'BNB', 'ADA', 'SOL'];
    final random = Random();
    
    return List.generate(20, (index) {
      final now = DateTime.now();
      final type = FeedType.values[random.nextInt(FeedType.values.length)];
      
      return SocialFeed(
        id: 'feed_$index',
        playerName: names[random.nextInt(names.length)],
        action: '',
        data: _generateFeedData(type, random, cryptos),
        timestamp: now.subtract(Duration(minutes: index * 5)),
        type: type,
      );
    });
  }

  static Map<String, dynamic> _generateFeedData(FeedType type, Random random, List<String> cryptos) {
    switch (type) {
      case FeedType.trade:
        final crypto = cryptos[random.nextInt(cryptos.length)];
        final amount = (random.nextDouble() * 10).toStringAsFixed(4);
        final price = random.nextDouble() * 50000;
        return {
          'type': random.nextBool() ? 'buy' : 'sell',
          'crypto': crypto,
          'amount': amount,
          'total': (double.parse(amount) * price).toStringAsFixed(2),
        };
      
      case FeedType.achievement:
        final achievements = ['Первая покупка', 'Майнер', 'Тысячник', 'Миллионер'];
        return {'title': achievements[random.nextInt(achievements.length)]};
      
      case FeedType.level_up:
        return {'level': random.nextInt(20) + 1};
      
      case FeedType.tournament:
        return {
          'place': random.nextInt(10) + 1,
          'tournament': 'Недельная прибыль',
        };
      
      default:
        return {};
    }
  }
}

enum FeedType {
  trade,
  achievement,
  level_up,
  tournament,
}

// Расширенная статистика игрока
class PlayerStats {
  int tradesCount = 0;
  double totalProfit = 0.0;
  double totalLoss = 0.0;
  int miningRigsCount = 0;
  int maxHoldTime = 0; // в секундах
  int dailyTrades = 0;
  DateTime lastTradeTime = DateTime.now();
  Map<String, int> cryptoTrades = {}; // символ криптовалюты -> количество сделок
  Map<String, double> cryptoProfits = {}; // символ криптовалюты -> прибыль
  
  double get winRate {
    if (tradesCount == 0) return 0.0;
    return (totalProfit / (totalProfit + totalLoss.abs())) * 100;
  }
  
  double get netProfit => totalProfit - totalLoss.abs();
  
  String get favoriteCrypto {
    if (cryptoTrades.isEmpty) return 'Нет';
    return cryptoTrades.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
  
  Map<String, int> toMap() {
    return {
      'trades_count': tradesCount,
      'total_profit': totalProfit.round(),
      'total_loss': totalLoss.abs().round(),
      'mining_rigs_count': miningRigsCount,
      'max_hold_time': maxHoldTime,
      'daily_trades': dailyTrades,
    };
  }
}