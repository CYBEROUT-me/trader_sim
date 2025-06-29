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
      
      if (_gameState.balance != oldBalance) {
        _animateBalanceChange();
      }
      
      _checkForNewEvents();
      
      if (_gameState.tickCounter % 10 == 0) {
        _gameState.saveProgress();
      }
      
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
          if (_showTopBanner) _buildTopBanner(),
          if (_selectedIndex == 0 && _showInfoPanel) _buildTradingInfoPanel(),
          if (_selectedIndex == 0 && !_showInfoPanel) _buildShowInfoButton(),
          if (_lastNotification != null) _buildNotification(),
          Expanded(child: pages[_selectedIndex]),
          if (_showBottomInterstitial) _buildBottomAd(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Icon(
                _gameState.traderStatus.icon,
                color: _gameState.traderStatus.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              // Ограничиваем ширину имени игрока
              Flexible(
                flex: 2,
                child: Text(
                  _gameState.playerName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              // Фиксированная ширина для баланса
              Flexible(
                flex: 1,
                child: _buildBalanceDisplay(),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, size: 20),
          onPressed: _startTutorial,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        IconButton(
          icon: const Icon(Icons.notifications, size: 20),
          onPressed: () => _showNotification('🎉 Тестовое уведомление!'),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '\$${_gameState.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02C076),
                  ),
                  maxLines: 1,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 10,
                      color: _gameState.traderStatus.color,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${_gameState.reputation}',
                      style: TextStyle(
                        fontSize: 10,
                        color: _gameState.traderStatus.color,
                      ),
                    ),
                  ],
                ),
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
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 50),
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            const Icon(Icons.trending_up, color: Color(0xFF02C076), size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  topGainer != null 
                    ? 'Лидер: ${topGainer.symbol} +${topGainer.changePercent.toStringAsFixed(1)}% • $ownedCryptos/$totalCryptos'
                    : 'Загрузка... • $ownedCryptos/$totalCryptos',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                icon: const Icon(Icons.close, size: 14, color: Colors.grey),
                onPressed: () => setState(() => _showTopBanner = false),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotification() {
    return SlideTransition(
      position: _notificationSlide,
      child: Container(
        margin: const EdgeInsets.all(8),
        constraints: const BoxConstraints(maxHeight: 60),
        padding: const EdgeInsets.all(8),
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
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 24,
              height: 24,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black, size: 14),
                onPressed: () {
                  _notificationController.reverse();
                  setState(() => _lastNotification = null);
                  _notificationTimer?.cancel();
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAd() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 70, minHeight: 60),
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
                    const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '💰 Заработай на криптовалютах!',
                          style: TextStyle(
                            color: Color(0xFFF0B90B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _showBottomInterstitial = false);
                          _showNotification('🎁 Получен бонус +100\$!');
                          _gameState.balance += 100;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF02C076),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'ПОЛУЧИТЬ БОНУС',
                            style: TextStyle(fontSize: 9, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 16),
                  onPressed: () => setState(() => _showBottomInterstitial = false),
                  padding: EdgeInsets.zero,
                ),
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
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Вычисляем доступную ширину для каждого элемента
              final itemWidth = constraints.maxWidth / 6;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.trending_up, 'Торговля', itemWidth),
                  _buildNavItem(1, Icons.memory, 'Майнинг', itemWidth),
                  _buildNavItem(2, Icons.star, 'Статус', itemWidth),
                  _buildNavItem(3, Icons.event, 'События', itemWidth),
                  _buildNavItem(4, Icons.newspaper, 'Новости', itemWidth),
                  _buildNavItem(5, Icons.person, 'Профиль', itemWidth),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, double maxWidth) {
    final isSelected = _selectedIndex == index;
    return SizedBox(
      width: maxWidth,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedIndex = index);
          HapticFeedback.selectionClick();
          
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
              Icon(
                icon,
                color: isSelected ? const Color(0xFFF0B90B) : Colors.grey,
                size: isSelected ? 22 : 20,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFF0B90B) : Colors.grey,
                      fontSize: 8,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradingInfoPanel() {
    final totalPortfolio = _gameState.cryptos.fold<double>(
      0.0, (sum, crypto) => sum + (crypto.holding * crypto.price),
    );
    final positiveCount = _gameState.cryptos.where((c) => c.isPositive).length;
    final activeEvents = _gameState.news.where((n) => n.isActive).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(10),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Первая строка
          Row(
            children: [
              Icon(
                _gameState.traderStatus.icon,
                color: _gameState.traderStatus.color,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${_gameState.traderStatus.name} • Портфель: \$${totalPortfolio.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              if (activeEvents > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0B90B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$activeEvents событий',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          // Вторая строка со статистикой
          Row(
            children: [
              _buildQuickStat('📈', '$positiveCount растут', const Color(0xFF02C076)),
              const SizedBox(width: 8),
              _buildQuickStat('⚡', 'Ур.${_gameState.level}', const Color(0xFFF0B90B)),
              const SizedBox(width: 8),
              _buildQuickStat('💰', '${_gameState.miningRigs.length}ригов', Colors.purple),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showInfoPanel = false),
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.grey[600],
                  size: 18,
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
          onTap: () => setState(() => _showInfoPanel = true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0B90B).withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFF0B90B),
                  size: 14,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Показать панель',
                  style: TextStyle(
                    color: Color(0xFFF0B90B),
                    fontSize: 9,
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
    return Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 2),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // СИСТЕМА ТУТОРИАЛА (остается без изменений)
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
      TutorialStep('Добро пожаловать в Crypto Tycoon!', 'Здесь вы можете торговать криптовалютами и зарабатывать деньги.', 0),
      TutorialStep('Торговля', 'Покупайте и продавайте криптовалюты. Следите за графиками!', 0),
      TutorialStep('Майнинг', 'Купите оборудование для пассивного дохода.', 1),
      TutorialStep('Статус', 'Повышайте репутацию и покупайте предметы роскоши.', 2),
      TutorialStep('События', 'Участвуйте в событиях и квестах для получения наград.', 3),
      TutorialStep('Новости', 'Следите за новостями - они влияют на курсы!', 4),
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
            GestureDetector(
              onTap: _endTutorial,
              child: Container(color: Colors.transparent),
            ),
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
                          style: TextButton.styleFrom(foregroundColor: Colors.grey),
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
}

class TutorialStep {
  final String title;
  final String description;
  final int targetIndex;

  TutorialStep(this.title, this.description, this.targetIndex);
}