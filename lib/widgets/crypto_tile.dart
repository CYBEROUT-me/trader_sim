import 'package:flutter/material.dart';
import '../models/crypto_currency.dart';
import '../models/game_state.dart';
import '../screens/crypto_detail_page.dart';

class CryptoTile extends StatelessWidget {
  final CryptoCurrency crypto;
  final GameState gameState;
  final VoidCallback onTap;

  const CryptoTile({
    super.key,
    required this.crypto,
    required this.gameState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: crypto.isPositive 
            ? const Color(0xFF02C076) 
            : const Color(0xFFF6465D),
          child: Text(
            crypto.symbol.length > 3 ? crypto.symbol.substring(0, 3) : crypto.symbol,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                crypto.symbol,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (crypto.holding > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0B90B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${crypto.holding.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          crypto.name,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${crypto.price.toStringAsFixed(crypto.price > 1 ? 2 : 6)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${crypto.isPositive ? '+' : ''}${crypto.changePercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: crypto.isPositive 
                    ? const Color(0xFF02C076) 
                    : const Color(0xFFF6465D),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        onTap: () => _openDetailPage(context),
        onLongPress: onTap, // Долгое нажатие для быстрой торговли
      ),
    );
  }

  void _openDetailPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CryptoDetailPage(
          crypto: crypto,
          gameState: gameState,
        ),
      ),
    );
  }
}