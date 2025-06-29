import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../models/trader_status.dart';
import '../models/luxury_item.dart';

class StatusPage extends StatefulWidget {
  final GameState gameState;

  const StatusPage({super.key, required this.gameState});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _prestigeAnimController;
  late Animation<double> _prestigeGlow;
  final String _selectedCategory = 'Все';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _prestigeAnimController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _prestigeGlow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _prestigeAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _prestigeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Рекламный баннер
        _buildAdBanner(),
        
        // Заголовок статуса
        _buildStatusHeader(),
        
        // TabBar
        _buildTabBar(),
        
        // Контент
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLuxuryCategory('Транспорт'),
              _buildLuxuryCategory('Недвижимость'),
              _buildLuxuryCategoryMixed(['Роскошь', 'Технологии']),
              _buildAchievementsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdBanner() {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.gameState.traderStatus.color.withOpacity(0.2),
            const Color(0xFFF0B90B).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF0B90B).withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '💎 Повышай статус и открывай новые возможности!',
                style: const TextStyle(
                  color: Color(0xFFF0B90B),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showPrestigeDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0B90B),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(80, 32),
              ),
              child: const Text(
                'ПРЕСТИЖ',
                style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    final status = widget.gameState.traderStatus;
    final nextStatus = TraderStatus.statuses.firstWhere(
      (s) => s.minReputation > widget.gameState.reputation,
      orElse: () => status,
    );
    final progress = nextStatus != status 
        ? widget.gameState.reputation / nextStatus.minReputation 
        : 1.0;

    return AnimatedBuilder(
      animation: _prestigeGlow,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2329),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: status.color.withOpacity(_prestigeGlow.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: status.color.withOpacity(_prestigeGlow.value * 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: status.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      status.icon,
                      color: status.color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: status.color,
                          ),
                        ),
                        Text(
                          status.description,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Color(0xFFF0B90B), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.gameState.reputation}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF0B90B),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Бонус: +${((status.tradingBonus - 1) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Color(0xFF02C076),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              if (nextStatus != status) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'До ${nextStatus.name}:',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '${nextStatus.minReputation - widget.gameState.reputation} репутации',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [status.color, nextStatus.color],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% до следующего уровня',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF1E2329),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFF0B90B),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFFF0B90B),
        isScrollable: false,
        labelStyle: const TextStyle(fontSize: 12),
        tabs: const [
          Tab(text: 'Транспорт'),
          Tab(text: 'Дома'),
          Tab(text: 'Роскошь'),
          Tab(text: 'Награды'),
        ],
      ),
    );
  }

  Widget _buildLuxuryCategory(String category) {
    final items = LuxuryItem.items.where((item) => item.category == category).toList();
    return _buildItemsList(items);
  }

  Widget _buildLuxuryCategoryMixed(List<String> categories) {
    final items = LuxuryItem.items.where((item) => categories.contains(item.category)).toList();
    return _buildItemsList(items);
  }

  Widget _buildItemsList(List<LuxuryItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Фильтры
            _buildFilters(items),
            
            // Список предметов
            Expanded(
              child: items.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildLuxuryItemCard(item);
                    },
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters(List<LuxuryItem> items) {
    final ownedCount = items.where((item) => widget.gameState.ownedLuxuryItems.contains(item.name)).length;
    final availableCount = items.where((item) => 
      !widget.gameState.ownedLuxuryItems.contains(item.name) && 
      widget.gameState.balance >= item.price
    ).length;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _buildFilterChip('Все', items.length, true),
          const SizedBox(width: 8),
          _buildFilterChip('Доступно', availableCount, false),
          const SizedBox(width: 8),
          _buildFilterChip('Куплено', ownedCount, false),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.grey),
            onPressed: () => _showSortDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0B90B) : const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFFF0B90B) : Colors.grey,
        ),
      ),
      child: Text(
        '$label ($count)',
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey,
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Нет доступных предметов',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Зарабатывайте больше, чтобы открыть новые покупки!',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryItemCard(LuxuryItem item) {
    final isOwned = widget.gameState.ownedLuxuryItems.contains(item.name);
    final canAfford = widget.gameState.balance >= item.price && !isOwned;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: const Color(0xFF1E2329),
        child: InkWell(
          onTap: canAfford ? () => _buyLuxuryItem(item) : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Иконка предмета
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 24,
                      ),
                    ),
                    if (isOwned)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF02C076),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                
                // Информация о предмете
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOwned ? const Color(0xFF02C076) : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Color(0xFFF0B90B)),
                          const SizedBox(width: 4),
                          Text(
                            '+${item.reputationBonus} репутации',
                            style: const TextStyle(
                              color: Color(0xFFF0B90B),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Цена и статус
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isOwned) ...[
                      const Icon(Icons.check_circle, color: Color(0xFF02C076)),
                      const Text(
                        'КУПЛЕНО',
                        style: TextStyle(
                          color: Color(0xFF02C076),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '\$${item.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: canAfford ? Colors.white : Colors.grey,
                        ),
                      ),
                      if (!canAfford && !isOwned)
                        const Text(
                          'НЕ ХВАТАЕТ',
                          style: TextStyle(
                            color: Color(0xFFF6465D),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    final completedAchievements = widget.gameState.achievements.where((a) => a.isCompleted).toList();
    final pendingAchievements = widget.gameState.achievements.where((a) => !a.isCompleted).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Статистика достижений
                _buildAchievementStats(),
                const SizedBox(height: 16),
                
                // Завершенные достижения
                if (completedAchievements.isNotEmpty) ...[
                  const Text(
                    '🏆 Полученные награды',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF02C076),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...completedAchievements.map((achievement) => _buildAchievementCard(achievement, true)),
                  const SizedBox(height: 16),
                ],
                
                // Ожидающие достижения
                if (pendingAchievements.isNotEmpty) ...[
                  const Text(
                    '🎯 В процессе',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...pendingAchievements.map((achievement) => _buildAchievementCard(achievement, false)),
                ],
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementStats() {
    final total = widget.gameState.achievements.length;
    final completed = widget.gameState.achievements.where((a) => a.isCompleted).length;
    final totalReputation = widget.gameState.achievements
        .where((a) => a.isCompleted)
        .fold(0, (sum, a) => sum + a.reputationReward);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0B90B).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '$completed / $total',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF0B90B),
                  ),
                ),
                const Text(
                  'Достижений',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$totalReputation',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02C076),
                  ),
                ),
                const Text(
                  'Репутации',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${((completed / total) * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Прогресс',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(achievement, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(8),
        border: isCompleted 
          ? Border.all(color: const Color(0xFF02C076), width: 1)
          : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isCompleted ? const Color(0xFF02C076) : Colors.grey).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? const Color(0xFF02C076) : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? const Color(0xFF02C076) : Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  achievement.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+${achievement.reputationReward}',
                    style: TextStyle(
                      color: isCompleted ? const Color(0xFFF0B90B) : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    isCompleted ? Icons.star : Icons.star_border,
                    color: isCompleted ? const Color(0xFFF0B90B) : Colors.grey,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _buyLuxuryItem(LuxuryItem item) {
    HapticFeedback.mediumImpact();
    widget.gameState.buyLuxuryItem(item);
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(item.icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Куплен ${item.name}! +${item.reputationBonus} репутации'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF02C076),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2329),
        title: const Text('Сортировка'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('По цене'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('По репутации'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('По алфавиту'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrestigeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2329),
        title: const Text('Система престижа'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Престиж позволяет начать игру заново с дополнительными бонусами:',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 12),
            Text('• Увеличенный стартовый капитал'),
            Text('• Бонус к доходу от майнинга'),
            Text('• Эксклюзивные предметы роскоши'),
            Text('• Особые достижения'),
            SizedBox(height: 12),
            Text(
              'Требования: 1,000,000\$ + статус Миллиардер',
              style: TextStyle(color: Color(0xFFF0B90B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}