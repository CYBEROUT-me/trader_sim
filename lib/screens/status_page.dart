import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/trader_status.dart';
import '../models/luxury_item.dart';

class StatusPage extends StatefulWidget {
  final GameState gameState;

  const StatusPage({super.key, required this.gameState});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatusHeader(),
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF0B90B),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFF0B90B),
          tabs: const [
            Tab(text: 'Транспорт'),
            Tab(text: 'Недвижимость'),
            Tab(text: 'Роскошь'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLuxuryCategory('Транспорт'),
              _buildLuxuryCategory('Недвижимость'),
              _buildLuxuryCategoryMixed(['Роскошь', 'Технологии']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHeader() {
    final status = widget.gameState.traderStatus;
    final nextStatus = TraderStatus.statuses.firstWhere(
      (s) => s.minReputation > widget.gameState.reputation,
      orElse: () => status,
    );

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  status.icon,
                  color: status.color,
                  size: 32,
                ),
                const SizedBox(width: 12),
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
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
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
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (nextStatus != status) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'До ${nextStatus.name}:',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    '${nextStatus.minReputation - widget.gameState.reputation} репутации',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: widget.gameState.reputation / nextStatus.minReputation,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(status.color),
              ),
            ],
          ],
        ),
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
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = widget.gameState.ownedLuxuryItems.contains(item.name);
        final canAfford = widget.gameState.balance >= item.price && !isOwned;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
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
            title: Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isOwned ? const Color(0xFF02C076) : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFF0B90B)),
                    const SizedBox(width: 4),
                    Text(
                      '+${item.reputationBonus} репутации',
                      style: const TextStyle(
                        color: Color(0xFFF0B90B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: isOwned
              ? const Icon(Icons.check_circle, color: Color(0xFF02C076))
              : Text(
                  '\$${item.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canAfford ? Colors.white : Colors.grey,
                  ),
                ),
            onTap: canAfford ? () {
              widget.gameState.buyLuxuryItem(item);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Куплен ${item.name}! +${item.reputationBonus} репутации'),
                  backgroundColor: const Color(0xFF02C076),
                ),
              );
            } : null,
          ),
        );
      },
    );
  }
}