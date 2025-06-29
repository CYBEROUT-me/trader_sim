import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../models/enhanced_game_content.dart';

class EventsPage extends StatefulWidget {
  final GameState gameState;

  const EventsPage({super.key, required this.gameState});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Рекламный баннер
        _buildAdBanner(),
        
        // TabBar
        Container(
          color: const Color(0xFF1E2329),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFF0B90B),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFF0B90B),
            isScrollable: false,
            tabs: const [
              Tab(text: 'События'),
              Tab(text: 'Квесты'),
              Tab(text: 'Турниры'),
              Tab(text: 'Лента'),
            ],
          ),
        ),
        
        // TabBar Content с правильным Expanded
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEventsTab(),
              _buildQuestsTab(),
              _buildTournamentsTab(),
              _buildSocialFeedTab(),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2329), Color(0xFF0B0E11)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF0B90B).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '🎮 Участвуй в событиях и получай награды!',
                style: TextStyle(
                  color: Color(0xFFF0B90B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎁 Получен ежедневный бонус!'),
                  backgroundColor: Color(0xFF02C076),
                ),
              );
            },
            child: const Text('ПОЛУЧИТЬ'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    final activeEvents = GameEvent.getAllEvents().where((e) => e.isActive).toList();
    final allEvents = GameEvent.getAllEvents();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Активные события
                if (activeEvents.isNotEmpty) ...[
                  _buildSectionHeader('🔥 Активные события', activeEvents.length),
                  const SizedBox(height: 8),
                  ...activeEvents.map((event) => _buildActiveEventCard(event)),
                  const SizedBox(height: 16),
                ],

                // Все возможные события
                _buildSectionHeader('📅 Возможные события', allEvents.length),
                const SizedBox(height: 8),
                ...allEvents.map((event) => _buildEventCard(event)),
                
                // Отступ снизу для безопасности
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF0B90B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveEventCard(GameEvent event) {
    final timeLeft = event.duration - event.activeTicks;
    final progress = event.activeTicks / event.duration;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: event.color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: event.color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок события
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: event.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(event.icon, color: event.color, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            event.description,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${timeLeft}s',
                          style: TextStyle(
                            color: event.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'осталось',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Прогресс бар
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(event.color),
                ),
                const SizedBox(height: 8),
                
                // Влияние на криптовалюты (только если есть место)
                if (event.cryptoImpact.isNotEmpty) ...[
                  const Text(
                    'Влияние:',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: event.cryptoImpact.entries.map((entry) {
                        final isPositive = entry.value > 1.0;
                        final impact = ((entry.value - 1.0) * 100).toStringAsFixed(0);
                        return Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D)).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${entry.key} ${isPositive ? '+' : ''}$impact%',
                            style: TextStyle(
                              color: isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventCard(GameEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: event.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(event.icon, color: event.color, size: 16),
        ),
        title: Text(
          event.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          event.description,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: Text(
          '${(event.probability * 100).toStringAsFixed(0)}%',
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildQuestsTab() {
    final quests = Quest.getAllQuests();
    final activeQuests = quests.where((q) => q.isActive && !q.isCompleted).toList();
    final completedQuests = quests.where((q) => q.isCompleted).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Активные квесты
                if (activeQuests.isNotEmpty) ...[
                  _buildSectionHeader('🎯 Активные квесты', activeQuests.length),
                  const SizedBox(height: 8),
                  ...activeQuests.map((quest) => _buildQuestCard(quest, false)),
                  const SizedBox(height: 16),
                ],

                // Завершенные квесты
                if (completedQuests.isNotEmpty) ...[
                  _buildSectionHeader('✅ Завершенные квесты', completedQuests.length),
                  const SizedBox(height: 8),
                  ...completedQuests.map((quest) => _buildQuestCard(quest, true)),
                ],
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestCard(Quest quest, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(12),
        border: isCompleted 
          ? Border.all(color: const Color(0xFF02C076), width: 1)
          : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: quest.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(quest.icon, color: quest.color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? const Color(0xFF02C076) : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      quest.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle, color: Color(0xFF02C076))
              else
                Text(
                  '${(quest.progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Color(0xFFF0B90B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: quest.progress,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(quest.color),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E11),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Награда: ${quest.rewards.money ?? 0}\$ + ${quest.rewards.reputation ?? 0} репутации',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentsTab() {
    final tournaments = Tournament.getActiveTournaments();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('🏆 Активные турниры', tournaments.length),
                const SizedBox(height: 8),
                ...tournaments.map((tournament) => _buildTournamentCard(tournament)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    final timeLeft = tournament.timeLeft;
    final isOngoing = tournament.isOngoing;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(12),
        border: isOngoing 
          ? Border.all(color: const Color(0xFFF0B90B), width: 2)
          : Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0B90B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.emoji_events, color: Color(0xFFF0B90B), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      tournament.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (isOngoing) ...[
                    const Text(
                      'АКТИВЕН',
                      style: TextStyle(
                        color: Color(0xFF02C076),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '${timeLeft.inHours}ч ${timeLeft.inMinutes.remainder(60)}м',
                      style: const TextStyle(
                        color: Color(0xFFF0B90B),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'СКОРО',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Призы в компактном виде
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E11),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Призы:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: tournament.prizes.entries.take(3).map((entry) {
                      final place = entry.key;
                      final prize = entry.value;
                      
                      Color placeColor;
                      switch (place) {
                        case 1: placeColor = const Color(0xFFFFD700); break;
                        case 2: placeColor = const Color(0xFFC0C0C0); break;
                        case 3: placeColor = const Color(0xFFCD7F32); break;
                        default: placeColor = Colors.grey;
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: placeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$place-е: \$${prize.money}',
                          style: TextStyle(color: placeColor, fontSize: 10),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Кнопка участия
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isOngoing ? null : () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎯 Вы зарегистрированы на турнир!'),
                    backgroundColor: Color(0xFF02C076),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0B90B),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                isOngoing ? 'Турнир идет' : 'Участвовать',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialFeedTab() {
    final feed = SocialFeed.generateFeed();

    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: feed.length,
          itemBuilder: (context, index) {
            final item = feed[index];
            return _buildFeedItem(item);
          },
        );
      },
    );
  }

  Widget _buildFeedItem(SocialFeed item) {
    IconData icon;
    Color color;
    
    switch (item.type) {
      case FeedType.trade:
        icon = item.data['type'] == 'buy' ? Icons.trending_up : Icons.trending_down;
        color = item.data['type'] == 'buy' ? const Color(0xFF02C076) : const Color(0xFFF6465D);
        break;
      case FeedType.achievement:
        icon = Icons.emoji_events;
        color = const Color(0xFFF0B90B);
        break;
      case FeedType.level_up:
        icon = Icons.trending_up;
        color = const Color(0xFF02C076);
        break;
      case FeedType.tournament:
        icon = Icons.emoji_events;
        color = Colors.purple;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayText,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(item.timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'только что';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ч назад';
    } else {
      return '${difference.inDays} дн назад';
    }
  }
}