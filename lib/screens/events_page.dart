import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/enhanced_game_content.dart';

class EventsPage extends StatefulWidget {
  final GameState gameState;

  const EventsPage({super.key, required this.gameState});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2329),
        title: const Text('События и активности'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF0B90B),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFF0B90B),
          tabs: const [
            Tab(text: 'События'),
            Tab(text: 'Квесты'),
            Tab(text: 'Турниры'),
            Tab(text: 'Лента'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsTab(),
          _buildQuestsTab(),
          _buildTournamentsTab(),
          _buildSocialFeedTab(),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    final activeEvents = GameEvent.getAllEvents().where((e) => e.isActive).toList();
    final allEvents = GameEvent.getAllEvents();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Активные события
          if (activeEvents.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.flash_on, color: Color(0xFFF0B90B)),
                const SizedBox(width: 8),
                const Text(
                  'Активные события',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...activeEvents.map((event) => _buildActiveEventCard(event)),
            const SizedBox(height: 24),
          ],

          // Все возможные события
          Row(
            children: [
              const Icon(Icons.event, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Возможные события',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...allEvents.map((event) => _buildEventCard(event)),
        ],
      ),
    );
  }

  Widget _buildActiveEventCard(GameEvent event) {
    final timeLeft = event.duration - event.activeTicks;
    final progress = event.activeTicks / event.duration;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: event.color, width: 2),
        boxShadow: [
          BoxShadow(
            color: event.color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: event.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(event.icon, color: event.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      event.description,
                      style: const TextStyle(color: Colors.grey),
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
                    ),
                  ),
                  const Text(
                    'осталось',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(event.color),
          ),
          const SizedBox(height: 8),
          if (event.cryptoImpact.isNotEmpty) ...[
            const Text(
              'Влияние на криптовалюты:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: event.cryptoImpact.entries.map((entry) {
                final isPositive = entry.value > 1.0;
                final impact = ((entry.value - 1.0) * 100).toStringAsFixed(0);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D)).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entry.key} ${isPositive ? '+' : ''}${impact}%',
                    style: TextStyle(
                      color: isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventCard(GameEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: event.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(event.icon, color: event.color, size: 20),
        ),
        title: Text(
          event.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          event.description,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          '${(event.probability * 100).toStringAsFixed(0)}%',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildQuestsTab() {
    final quests = Quest.getAllQuests();
    final activeQuests = quests.where((q) => q.isActive && !q.isCompleted).toList();
    final completedQuests = quests.where((q) => q.isCompleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Активные квесты
          if (activeQuests.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.flag, color: Color(0xFFF0B90B)),
                const SizedBox(width: 8),
                const Text(
                  'Активные квесты',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...activeQuests.map((quest) => _buildQuestCard(quest, false)),
            const SizedBox(height: 24),
          ],

          // Завершенные квесты
          if (completedQuests.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF02C076)),
                const SizedBox(width: 8),
                const Text(
                  'Завершенные квесты',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...completedQuests.map((quest) => _buildQuestCard(quest, true)),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestCard(Quest quest, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: quest.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(quest.icon, color: quest.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? const Color(0xFF02C076) : Colors.white,
                      ),
                    ),
                    Text(
                      quest.description,
                      style: const TextStyle(color: Colors.grey),
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
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: quest.progress,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(quest.color),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E11),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Награды:',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: quest.rewards.toMap().entries
                  .where((entry) => entry.value != null)
                  .map((entry) => Text('${entry.key}: ${entry.value}'))
                  .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentsTab() {
    final tournaments = Tournament.getActiveTournaments();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFFF0B90B)),
              const SizedBox(width: 8),
              const Text(
                'Активные турниры',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tournaments.map((tournament) => _buildTournamentCard(tournament)),
        ],
      ),
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    final timeLeft = tournament.timeLeft;
    final isOngoing = tournament.isOngoing;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0B90B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emoji_events, color: Color(0xFFF0B90B), size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      tournament.description,
                      style: const TextStyle(color: Colors.grey),
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
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${timeLeft.inHours}ч ${timeLeft.inMinutes.remainder(60)}м',
                      style: const TextStyle(
                        color: Color(0xFFF0B90B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'СКОРО',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E11),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Призы:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...tournament.prizes.entries.map((entry) {
                  final place = entry.key;
                  final prize = entry.value;
                  
                  Color placeColor;
                  switch (place) {
                    case 1:
                      placeColor = const Color(0xFFFFD700); // Золото
                      break;
                    case 2:
                      placeColor = const Color(0xFFC0C0C0); // Серебро
                      break;
                    case 3:
                      placeColor = const Color(0xFFCD7F32); // Бронза
                      break;
                    default:
                      placeColor = Colors.grey;
                  }
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: placeColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$place',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '\\${prize.money} + ${prize.reputation} репутации',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isOngoing ? null : () {
                // Логика участия в турнире
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Вы зарегистрированы на турнир!'),
                    backgroundColor: Color(0xFF02C076),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0B90B),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                isOngoing ? 'Турнир идет' : 'Участвовать',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: feed.length,
      itemBuilder: (context, index) {
        final item = feed[index];
        return _buildFeedItem(item);
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayText,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(item.timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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