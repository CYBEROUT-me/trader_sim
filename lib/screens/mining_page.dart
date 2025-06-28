import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/mining_rig.dart';

class MiningPage extends StatelessWidget {
  final GameState gameState;

  const MiningPage({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMiningStats(),
          const SizedBox(height: 20),
          const Text(
            'Оборудование для майнинга',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: MiningRigType.available.length,
              itemBuilder: (context, index) {
                final rigType = MiningRigType.available[index];
                return _buildMiningRigCard(context, rigType);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiningStats() {
    double totalHashrate = gameState.miningRigs.fold(0, (sum, rig) => sum + rig.type.hashrate);
    double baseEarnings = gameState.miningRigs.fold(0, (sum, rig) => sum + rig.minePerSecond);
    double bonusEarnings = baseEarnings * gameState.traderStatus.tradingBonus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Активных ригов:'),
                Text(
                  '${gameState.miningRigs.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF0B90B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Хешрейт:'),
                Text(
                  '${totalHashrate.toStringAsFixed(0)} H/s',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02C076),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Доход/сек:'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${bonusEarnings.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF02C076),
                      ),
                    ),
                    if (gameState.traderStatus.tradingBonus > 1.0)
                      Text(
                        'Статус бонус: +${((gameState.traderStatus.tradingBonus - 1) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFF0B90B),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiningRigCard(BuildContext context, MiningRigType rigType) {
    final ownedCount = gameState.miningRigs.where((r) => r.type.name == rigType.name).length;
    final canAfford = gameState.balance >= rigType.price;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.memory, color: Color(0xFFF0B90B)),
        title: Row(
          children: [
            Text(rigType.name),
            if (ownedCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF02C076),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$ownedCount',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rigType.description),
            Text('${rigType.hashrate.toStringAsFixed(0)} H/s'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${rigType.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: canAfford ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
        onTap: canAfford ? () {
          gameState.buyMiningRig(rigType);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Куплен ${rigType.name}!'),
              backgroundColor: const Color(0xFF02C076),
            ),
          );
        } : null,
      ),
    );
  }
}