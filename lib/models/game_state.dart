import 'dart:convert';
import 'dart:math';
import 'crypto_currency.dart';
import 'mining_rig.dart';
import 'game_news.dart';
import 'achievement.dart';
import 'trader_status.dart';
import 'luxury_item.dart';

class GameState {
  String playerName = 'CryptoTrader';
  double balance = 1000.0;
  int level = 1;
  double experience = 0.0;
  double experienceToNext = 100.0;
  int reputation = 0;
  
  List<CryptoCurrency> cryptos = [];
  List<MiningRig> miningRigs = [];
  List<GameNews> news = [];
  List<Achievement> achievements = [];
  List<String> ownedLuxuryItems = [];
  
  final Random _random = Random();
  int tickCounter = 0;

  TraderStatus get traderStatus => TraderStatus.getStatus(reputation);

  GameState() {
    _initializeCryptos();
    _initializeNews();
    _initializeAchievements();
  }

  void _initializeCryptos() {
    cryptos = [
      CryptoCurrency('BTC', 'Bitcoin', 45000.0),
      CryptoCurrency('ETH', 'Ethereum', 2800.0),
      CryptoCurrency('BNB', 'Binance Coin', 320.0),
      CryptoCurrency('ADA', 'Cardano', 1.2),
      CryptoCurrency('SOL', 'Solana', 95.0),
      CryptoCurrency('DOT', 'Polkadot', 28.5),
      CryptoCurrency('DOGE', 'Dogecoin', 0.15),
      CryptoCurrency('SHIB', 'Shiba Inu', 0.000025),
    ];
  }

  void _initializeNews() {
    news = [
      GameNews('🚀 Илон Маск твитнул про Bitcoin!', NewsImpact.positive, 'BTC'),
      GameNews('⚠️ Китай запретил майнинг', NewsImpact.negative, 'BTC'),
      GameNews('💎 Ethereum обновление успешно', NewsImpact.positive, 'ETH'),
      GameNews('📈 Binance запустила новый продукт', NewsImpact.positive, 'BNB'),
      GameNews('🔥 Кит продал 1000 BTC', NewsImpact.negative, 'BTC'),
      GameNews('🌟 Solana Partnership с Microsoft', NewsImpact.positive, 'SOL'),
      GameNews('📉 SEC расследует Binance', NewsImpact.negative, 'BNB'),
      GameNews('💰 Dogecoin принят в Tesla', NewsImpact.positive, 'DOGE'),
    ];
  }

  void _initializeAchievements() {
    achievements = [
      Achievement('Первая покупка', 'Купите любую криптовалюту', false, 10),
      Achievement('Майнер', 'Купите первое оборудование для майнинга', false, 20),
      Achievement('Тысячник', 'Накопите \$1,000', false, 50),
      Achievement('Модник', 'Купите первый предмет роскоши', false, 30),
      Achievement('Миллионер', 'Накопите \$1,000,000', false, 1000),
      Achievement('Коллекционер', 'Купите 5 предметов роскоши', false, 500),
      Achievement('Ходлер', 'Держите позицию криптовалюты более 60 секунд', false, 100),
      Achievement('Трейдер дня', 'Совершите 10 сделок', false, 200),
    ];
  }

  // Сохранение и загрузка прогресса
  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'balance': balance,
      'level': level,
      'experience': experience,
      'experienceToNext': experienceToNext,
      'reputation': reputation,
      'cryptos': cryptos.map((c) => c.toJson()).toList(),
      'miningRigs': miningRigs.map((r) => r.toJson()).toList(),
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'ownedLuxuryItems': ownedLuxuryItems,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    playerName = json['playerName'] ?? 'CryptoTrader';
    balance = json['balance']?.toDouble() ?? 1000.0;
    level = json['level'] ?? 1;
    experience = json['experience']?.toDouble() ?? 0.0;
    experienceToNext = json['experienceToNext']?.toDouble() ?? 100.0;
    reputation = json['reputation'] ?? 0;
    ownedLuxuryItems = List<String>.from(json['ownedLuxuryItems'] ?? []);
    
    if (json['cryptos'] != null) {
      for (int i = 0; i < cryptos.length && i < json['cryptos'].length; i++) {
        cryptos[i].fromJson(json['cryptos'][i]);
      }
    }
    
    if (json['achievements'] != null) {
      for (int i = 0; i < achievements.length && i < json['achievements'].length; i++) {
        achievements[i].fromJson(json['achievements'][i]);
      }
    }
  }

  // Упрощенная версия сохранения
  String? _savedData;
  
  Future<void> saveProgress() async {
    _savedData = jsonEncode(toJson());
  }

  Future<void> loadProgress() async {
    if (_savedData != null) {
      try {
        final data = jsonDecode(_savedData!);
        fromJson(data);
      } catch (e) {
        // Если ошибка при загрузке, используем значения по умолчанию
      }
    }
  }

  void update() {
    tickCounter++;
    
    _updatePrices();
    _processMining();
    
    if (tickCounter % 10 == 0) {
      _generateRandomNews();
    }
    
    _checkAchievements();
  }

  void _updatePrices() {
    for (var crypto in cryptos) {
      double change = (_random.nextDouble() - 0.5) * 0.02;
      
      for (var newsItem in news.where((n) => n.isActive)) {
        if (newsItem.affectedCrypto == crypto.symbol) {
          if (newsItem.impact == NewsImpact.positive) {
            change += 0.01;
          } else {
            change -= 0.01;
          }
        }
      }
      
      crypto.updatePrice(change);
    }
    
    for (var n in news) {
      n.tick();
    }
  }

  void _processMining() {
    for (var rig in miningRigs) {
      double earnings = rig.minePerSecond * traderStatus.tradingBonus;
      balance += earnings;
      _addExperience(0.1);
    }
  }

  void _generateRandomNews() {
    if (_random.nextDouble() < 0.3) {
      var randomNews = news[_random.nextInt(news.length)];
      randomNews.activate();
    }
  }

  void _addExperience(double exp) {
    experience += exp;
    if (experience >= experienceToNext) {
      level++;
      experience = 0;
      experienceToNext *= 1.5;
      reputation += 10;
    }
  }

  void _addReputation(int rep) {
    reputation += rep;
    if (reputation < 0) reputation = 0;
  }

  void _checkAchievements() {
    if (balance >= 1000 && !achievements[2].isCompleted) {
      achievements[2].complete();
      _addReputation(achievements[2].reputationReward);
    }
    
    if (balance >= 1000000 && !achievements[4].isCompleted) {
      achievements[4].complete();
      _addReputation(achievements[4].reputationReward);
    }
    
    if (ownedLuxuryItems.length >= 5 && !achievements[5].isCompleted) {
      achievements[5].complete();
      _addReputation(achievements[5].reputationReward);
    }
  }

  void buyCrypto(CryptoCurrency crypto, double amount) {
    double cost = crypto.price * amount * (2.0 - traderStatus.tradingBonus);
    if (balance >= cost) {
      balance -= cost;
      crypto.holding += amount;
      _addExperience(cost / 100);
      _addReputation((cost / 1000).round());
      
      if (!achievements[0].isCompleted) {
        achievements[0].complete();
        _addReputation(achievements[0].reputationReward);
      }
    }
  }

  void sellCrypto(CryptoCurrency crypto, double amount) {
    if (crypto.holding >= amount) {
      crypto.holding -= amount;
      double earnings = crypto.price * amount * traderStatus.tradingBonus;
      balance += earnings;
      _addExperience(earnings / 100);
      _addReputation((earnings / 1000).round());
    }
  }

  void buyMiningRig(MiningRigType type) {
    if (balance >= type.price) {
      balance -= type.price;
      miningRigs.add(MiningRig(type));
      _addExperience(type.price / 50);
      _addReputation((type.price / 500).round());
      
      if (!achievements[1].isCompleted) {
        achievements[1].complete();
        _addReputation(achievements[1].reputationReward);
      }
    }
  }

  void buyLuxuryItem(LuxuryItem item) {
    if (balance >= item.price && !ownedLuxuryItems.contains(item.name)) {
      balance -= item.price;
      ownedLuxuryItems.add(item.name);
      _addReputation(item.reputationBonus);
      
      if (ownedLuxuryItems.length == 1 && !achievements[3].isCompleted) {
        achievements[3].complete();
        _addReputation(achievements[3].reputationReward);
      }
    }
  }

  void setPlayerName(String name) {
    playerName = name.isEmpty ? 'CryptoTrader' : name;
    saveProgress();
  }
}