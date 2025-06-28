import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/crypto_currency.dart';
import '../widgets/crypto_tile.dart';
import '../widgets/trade_dialog.dart';

class TradingPage extends StatelessWidget {
  final GameState gameState;

  const TradingPage({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: gameState.cryptos.length,
      itemBuilder: (context, index) {
        final crypto = gameState.cryptos[index];
        return CryptoTile(
          crypto: crypto,
          gameState: gameState,
          onTap: () => _showTradeDialog(context, crypto),
        );
      },
    );
  }

  void _showTradeDialog(BuildContext context, CryptoCurrency crypto) {
    showDialog(
      context: context,
      builder: (context) => TradeDialog(crypto: crypto, gameState: gameState),
    );
  }
}