import 'package:flutter/material.dart';
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

class _GameScreenState extends State<GameScreen> {
  int _selectedIndex = 0;
  Timer? _gameTimer;
  
  GameState _gameState = GameState();

  @override
  void initState() {
    super.initState();
    _loadGame();
    _startGameLoop();
  }

  void _loadGame() async {
    await _gameState.loadProgress();
    setState(() {});
  }

  void _startGameLoop() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _gameState.update();
      });
      // Автосохранение каждые 10 секунд
      if (_gameState.tickCounter % 10 == 0) {
        _gameState.saveProgress();
      }
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
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
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              _gameState.traderStatus.icon,
              color: _gameState.traderStatus.color,
            ),
            const SizedBox(width: 8),
            Text(_gameState.playerName),
            const Spacer(),
            _buildBalanceDisplay(),
          ],
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 80,
        color: const Color(0xFF1E2329),
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
    );
  }

  Widget _buildBalanceDisplay() {
    return Column(
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
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFF0B90B) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFF0B90B) : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}