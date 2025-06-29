import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/game_state.dart';
import 'trading_page.dart';
import 'mining_page.dart';
import 'status_page.dart';
import 'events_page.dart';
import 'news_page.dart';
import 'profile_page.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> 
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  Timer? _gameTimer;
  GameState _gameState = GameState();
  
  // Туториал
  bool _isFirstTime = true;
  bool _showingTutorial = false;
  int _tutorialStep = 0;
  OverlayEntry? _tutorialOverlay;
  
  // Анимации и уведомления
  late AnimationController _balanceAnimController;
  late AnimationController _notificationController;
  late Animation<double> _balanceScale;
  late Animation<Offset> _notificationSlide;
  
  String? _lastNotification;
  Timer? _notificationTimer;
  
  // Реклама
  bool _showTopBanner = true;
  bool _showInfoPanel = true;
  bool _showBottomInterstitial = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGame();
    _checkFirstTime();
  }

  void _initializeAnimations() {
    _balanceAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _balanceScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _balanceAnimController, curve: Curves.elasticOut),
    );
    
    _notificationSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _notificationController, 
      curve: Curves.bounceOut,
    ));
  }

  void _loadGame() async {
    await _gameState.loadProgress();
    setState(() {});
    _startGameLoop();
  }

  void _checkFirstTime() async {
    // В реальном приложении проверили бы SharedPreferences
    if (_isFirstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTutorial();
      });
    }
  }

  void _startGameLoop() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final oldBalance = _gameState.balance;
      
      setState(() {
        _gameState.update();
      });
      
      // Анимация изменения баланса
      if (_gameState.balance != oldBalance) {
        _animateBalanceChange();
      }
      
      // Проверка на новые события
      _checkForNewEvents();
      
      // Автосохранение каждые 10 секунд
      if (_gameState.tickCounter % 10 == 0) {
        _gameState.saveProgress();
      }
      
      // Показать рекламу каждые 2 минуты
      if (_gameState.tickCounter % 120 == 0) {
        _showInterstitialAd();
      }
    });
  }

  void _animateBalanceChange() {
    _balanceAnimController.forward().then((_) {
      _balanceAnimController.reverse();
    });
  }

  void _checkForNewEvents() {
    final activeNews = _gameState.news.where((n) => n.isActive).toList();
    if (activeNews.isNotEmpty && activeNews.first.activeTicks == 1) {
      _showNotification('📰 ${activeNews.first.text}');
      HapticFeedback.lightImpact();
    }
  }

  void _showNotification(String message) {
    setState(() => _lastNotification = message);
    _notificationController.forward();
    
    _notificationTimer?.cancel();
    _notificationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _notificationController.reverse().then((_) {
          if (mounted) {
            setState(() => _lastNotification = null);
          }
        });
      }
    });
  }

  void _showInterstitialAd() {
    if (!_showBottomInterstitial) {
      setState(() => _showBottomInterstitial = true);
      Timer(const Duration(seconds: 5), () {
        setState(() => _showBottomInterstitial = false);
      });
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _notificationTimer?.cancel();
    _balanceAnimController.dispose();
    _notificationController.dispose();
    _tutorialOverlay?.remove();
    _gameState.saveProgress();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TradingPage(gameState: _gameState),
      MiningPage(gameState: _gameState),
      StatusPage(gameState: _gameState),
      EventsPage(gameState: _gameState),
      NewsPage(gameState: _gameState),
      ProfilePage(gameState: _gameState),
    ];

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Верхний рекламный баннер
          if (_showTopBanner) _buildTopBanner(),
          
          // Полезная информационная панель вместо простого уведомления
          if (_selectedIndex == 0 && _showInfoPanel) _buildTradingInfoPanel(),
          
          // Кнопка для показа скрытой панели
          if (_selectedIndex == 0 && !_showInfoPanel) _buildShowInfoButton(),
          
          // Уведомления (отдельно от информационной панели)
          if (_lastNotification != null) _buildNotification(),
          
          // Основной контент
          Expanded(child: pages[_selectedIndex]),
          
          // Нижняя реклама
          if (_showBottomInterstitial) _buildBottomAd(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Icon(
            _gameState.traderStatus.icon,
            color: _gameState.traderStatus.color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _gameState.playerName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          _buildBalanceDisplay(),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: _startTutorial,
        ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => _showNotification('🎉 Тестовое уведомление!'),
        ),
      ],
    );
  }

  Widget _buildBalanceDisplay() {
    return AnimatedBuilder(
      animation: _balanceScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _balanceScale.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$${_gameState.balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02C076),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 12,
                    color: _gameState.traderStatus.color,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${_gameState.reputation}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _gameState.traderStatus.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBanner() {
    final totalCryptos = _gameState.cryptos.length;
    final ownedCryptos = _gameState.cryptos.where((c) => c.holding > 0).length;
    final topGainer = _gameState.cryptos.isEmpty ? null : 
        _gameState.cryptos.reduce((a, b) => a.changePercent > b.changePercent ? a : b);
    
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E2329),
            const Color(0xFF0B0E11),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF02C076).withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.trending_up, color: const Color(0xFF02C076), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                topGainer != null 
                  ? 'Лидер роста: ${topGainer.symbol} +${topGainer.changePercent.toStringAsFixed(1)}% • $ownedCryptos/$totalCryptos валют'
                  : 'Рынок загружается... • $ownedCryptos/$totalCryptos валют',
                style: const TextStyle(color: Colors.white, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(4),
              child: IconButton(
                icon: const Icon(Icons.close, size: 14, color: Colors.grey),
                onPressed: () => setState(() => _showTopBanner = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotification() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: _lastNotification != null ? null : 0,
      child: _lastNotification != null ? SlideTransition(
        position: _notificationSlide,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0B90B),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _lastNotification!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black, size: 16),
                onPressed: () {
                  _notificationController.reverse();
                  setState(() => _lastNotification = null);
                  _notificationTimer?.cancel();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ) : const SizedBox.shrink(),
    );
  }

  Widget _buildBottomAd() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 70),
      color: const Color(0xFF1E2329),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '💰 Заработай на криптовалютах!',
                      style: TextStyle(
                        color: Color(0xFFF0B90B),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _showBottomInterstitial = false);
                        _showNotification('🎁 Получен бонус +100\$!');
                        _gameState.balance += 100;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02C076),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: const Size(0, 28),
                      ),
                      child: const Text(
                        'ПОЛУЧИТЬ БОНУС',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => setState(() => _showBottomInterstitial = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E2329),
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.trending_up, 'Торговля'),
              _buildNavItem(1, Icons.memory, 'Майнинг'),
              _buildNavItem(2, Icons.star, 'Статус'),
              _buildNavItem(3, Icons.event, 'События'),
              _buildNavItem(4, Icons.newspaper, 'Новости'),
              _buildNavItem(5, Icons.person, 'Профиль'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedIndex = index);
          HapticFeedback.selectionClick();
          
          // Показать подсказку для туториала
          if (_showingTutorial && _tutorialStep == index) {
            _nextTutorialStep();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0B90B).withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: isSelected ? const Color(0xFFF0B90B) : Colors.grey,
                  size: isSelected ? 24 : 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFF0B90B) : Colors.grey,
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // СИСТЕМА ТУТОРИАЛА
  void _startTutorial() {
    setState(() {
      _showingTutorial = true;
      _tutorialStep = 0;
    });
    _showTutorialStep();
  }

  void _showTutorialStep() {
    _tutorialOverlay?.remove();
    
    final steps = [
      TutorialStep(
        'Добро пожаловать в Crypto Tycoon!',
        'Здесь вы можете торговать криптовалютами и зарабатывать деньги.',
        0,
      ),
      TutorialStep(
        'Торговля',
        'Покупайте и продавайте криптовалюты. Следите за графиками!',
        0,
      ),
      TutorialStep(
        'Майнинг',
        'Купите оборудование для пассивного дохода.',
        1,
      ),
      TutorialStep(
        'Статус',
        'Повышайте репутацию и покупайте предметы роскоши.',
        2,
      ),
      TutorialStep(
        'События',
        'Участвуйте в событиях и квестах для получения наград.',
        3,
      ),
      TutorialStep(
        'Новости',
        'Следите за новостями - они влияют на курсы!',
        4,
      ),
    ];

    if (_tutorialStep < steps.length) {
      final step = steps[_tutorialStep];
      _tutorialOverlay = _createTutorialOverlay(step);
      Overlay.of(context).insert(_tutorialOverlay!);
    } else {
      _endTutorial();
    }
  }

  OverlayEntry _createTutorialOverlay(TutorialStep step) {
    return OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.7),
        child: Stack(
          children: [
            // Затемнение
            GestureDetector(
              onTap: _endTutorial,
              child: Container(color: Colors.transparent),
            ),
            
            // Подсветка таргета в нижней навигации
            if (step.targetIndex >= 0)
              Positioned(
                bottom: 20,
                left: (MediaQuery.of(context).size.width / 6) * step.targetIndex + 10,
                child: Container(
                  width: (MediaQuery.of(context).size.width / 6) - 20,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: const Color(0xFFF0B90B), width: 3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF0B90B).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            
            // Текст туториала
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: 20,
              right: 20,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2329),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0B90B), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF0B90B).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF0B90B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      step.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _endTutorial,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                          child: const Text('Пропустить'),
                        ),
                        ElevatedButton(
                          onPressed: _nextTutorialStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF0B90B),
                            foregroundColor: Colors.black,
                          ),
                          child: Text(_tutorialStep == 5 ? 'Готово' : 'Далее'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextTutorialStep() {
    _tutorialStep++;
    if (_tutorialStep <= 5) {
      _showTutorialStep();
    } else {
      _endTutorial();
    }
  }

  void _endTutorial() {
    _tutorialOverlay?.remove();
    _tutorialOverlay = null;
    setState(() {
      _showingTutorial = false;
      _isFirstTime = false;
    });
    
    _showNotification('🎉 Добро пожаловать в игру! Удачи в торговле!');
  }

  Widget _buildTradingInfoPanel() {
    final totalPortfolio = _gameState.cryptos.fold<double>(
      0.0, (sum, crypto) => sum + (crypto.holding * crypto.price),
    );
    final positiveCount = _gameState.cryptos.where((c) => c.isPositive).length;
    final activeEvents = _gameState.news.where((n) => n.isActive).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E2329),
            const Color(0xFF0B0E11),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF0B90B).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _gameState.traderStatus.icon,
                color: _gameState.traderStatus.color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${_gameState.traderStatus.name} • Портфель: \$${totalPortfolio.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (activeEvents > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0B90B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$activeEvents событий',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildQuickStat('📈', '$positiveCount растут', const Color(0xFF02C076)),
              const SizedBox(width: 12),
              _buildQuickStat('⚡', 'Уровень ${_gameState.level}', const Color(0xFFF0B90B)),
              const SizedBox(width: 12),
              _buildQuickStat('💰', '${_gameState.miningRigs.length} ригов', Colors.purple),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() => _showInfoPanel = false);
                },
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShowInfoButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Center(
        child: GestureDetector(
          onTap: () {
            setState(() => _showInfoPanel = true);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFF0B90B).withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_down,
                  color: const Color(0xFFF0B90B),
                  size: 16,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Показать панель',
                  style: TextStyle(
                    color: Color(0xFFF0B90B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String emoji, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final int targetIndex;

  TutorialStep(this.title, this.description, this.targetIndex);
}