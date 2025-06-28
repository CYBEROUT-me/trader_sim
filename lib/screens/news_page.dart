import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/game_news.dart';

class NewsPage extends StatelessWidget {
  final GameState gameState;

  const NewsPage({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final activeNews = gameState.news.where((n) => n.isActive).toList();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Актуальные новости',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (activeNews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.newspaper,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Пока нет активных новостей...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Новости появляются каждые 10 секунд\nи влияют на курсы криптовалют!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: activeNews.length,
                itemBuilder: (context, index) {
                  final news = activeNews[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: news.impact == NewsImpact.positive
                            ? const Color(0xFF02C076).withOpacity(0.2)
                            : const Color(0xFFF6465D).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          news.impact == NewsImpact.positive
                            ? Icons.trending_up
                            : Icons.trending_down,
                          color: news.impact == NewsImpact.positive
                            ? const Color(0xFF02C076)
                            : const Color(0xFFF6465D),
                        ),
                      ),
                      title: Text(
                        news.text,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Влияет ${20 - news.activeTicks} сек',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const Spacer(),
                              Text(
                                news.impact == NewsImpact.positive ? 'Рост' : 'Падение',
                                style: TextStyle(
                                  color: news.impact == NewsImpact.positive
                                    ? const Color(0xFF02C076)
                                    : const Color(0xFFF6465D),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: news.impact == NewsImpact.positive
                            ? const Color(0xFF02C076)
                            : const Color(0xFFF6465D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          news.affectedCrypto,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
}