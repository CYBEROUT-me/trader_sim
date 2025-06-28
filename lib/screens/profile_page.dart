import 'package:flutter/material.dart';
import '../models/game_state.dart';

class ProfilePage extends StatelessWidget {
  final GameState gameState;

  const ProfilePage({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 20),
          _buildStats(),
          const SizedBox(height: 20),
          const Text(
            'Достижения',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: gameState.achievements.length,
              itemBuilder: (context, index) {
                final achievement = gameState.achievements[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: achievement.isCompleted 
                          ? const Color(0xFF02C076).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        achievement.isCompleted 
                          ? Icons.check_circle 
                          : Icons.radio_button_unchecked,
                        color: achievement.isCompleted 
                          ? const Color(0xFF02C076) 
                          : Colors.grey,
                      ),
                    ),
                    title: Text(
                      achievement.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: achievement.isCompleted 
                          ? const Color(0xFF02C076) 
                          : null,
                      ),
                    ),
                    subtitle: Text(achievement.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (achievement.isCompleted) ...[
                          Text(
                            '+${achievement.reputationReward}',
                            style: const TextStyle(
                              color: Color(0xFFF0B90B),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: Color(0xFFF0B90B), size: 16),
                        ] else ...[
                          Text(
                            '+${achievement.reputationReward}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star_border, color: Colors.grey, size: 16),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: gameState.traderStatus.color,
              child: Icon(
                gameState.traderStatus.icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gameState.playerName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    gameState.traderStatus.name,
                    style: TextStyle(
                      color: gameState.traderStatus.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showEditNameDialog(context),
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(text: gameState.playerName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2329),
        title: const Text('Изменить имя'),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Имя трейдера',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              gameState.setPlayerName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final totalPortfolioValue = gameState.cryptos.fold<double>(
      0.0, 
      (sum, crypto) => sum + (crypto.holding * crypto.price),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Уровень:'),
                Text(
                  '${gameState.level}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF0B90B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: gameState.experience / gameState.experienceToNext,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF0B90B)),
            ),
            const SizedBox(height: 4),
            Text(
              'Опыт: ${gameState.experience.toStringAsFixed(0)}/${gameState.experienceToNext.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Наличные:'),
                Text(
                  '\$${gameState.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
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
                const Text('Портфель:'),
                Text(
                  '\$${totalPortfolioValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
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
                const Text('Общий капитал:'),
                Text(
                  '\$${(gameState.balance + totalPortfolioValue).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Предметы роскоши:'),
                Text(
                  '${gameState.ownedLuxuryItems.length}',
                  style: const TextStyle(
                    fontSize: 16,
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
                const Text('Майнинг фермы:'),
                Text(
                  '${gameState.miningRigs.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF0B90B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}