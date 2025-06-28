import 'package:flutter/material.dart';
import '../models/crypto_currency.dart';
import '../models/game_state.dart';

class TradeDialog extends StatefulWidget {
  final CryptoCurrency crypto;
  final GameState gameState;

  const TradeDialog({super.key, required this.crypto, required this.gameState});

  @override
  State<TradeDialog> createState() => _TradeDialogState();
}

class _TradeDialogState extends State<TradeDialog> {
  final _amountController = TextEditingController(text: '1.0');
  bool _isBuying = true;

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 1.0;
    final basePrice = widget.crypto.price * amount;
    final tradingBonus = widget.gameState.traderStatus.tradingBonus;
    final finalPrice = _isBuying 
      ? basePrice * (2.0 - tradingBonus) // Скидка при покупке
      : basePrice * tradingBonus; // Бонус при продаже

    return AlertDialog(
      backgroundColor: const Color(0xFF1E2329),
      title: Text('${_isBuying ? 'Купить' : 'Продать'} ${widget.crypto.symbol}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Цена:'),
              Text(
                '\$${widget.crypto.price.toStringAsFixed(widget.crypto.price > 1 ? 2 : 6)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Статус бонус:'),
              Text(
                '${_isBuying ? "Скидка" : "Бонус"}: ${((tradingBonus - 1) * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Color(0xFF02C076)),
              ),
            ],
          ),
          if (widget.crypto.holding > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('У вас:'),
                Text(
                  '${widget.crypto.holding.toStringAsFixed(4)}',
                  style: const TextStyle(color: Color(0xFFF0B90B)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Количество',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E11),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Базовая цена:'),
                    Text('\$${basePrice.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Итого:'),
                    Text(
                      '\$${finalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF02C076),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTradeButton(true, 'Купить'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTradeButton(false, 'Продать'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
      ],
    );
  }

  Widget _buildTradeButton(bool isBuy, String text) {
    return ElevatedButton(
      onPressed: () {
        setState(() => _isBuying = isBuy);
        _executeTrade();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isBuy 
          ? const Color(0xFF02C076) 
          : const Color(0xFFF6465D),
      ),
      child: Text(text),
    );
  }

  void _executeTrade() {
    final amount = double.tryParse(_amountController.text) ?? 1.0;
    
    if (_isBuying) {
      widget.gameState.buyCrypto(widget.crypto, amount);
    } else {
      widget.gameState.sellCrypto(widget.crypto, amount);
    }
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_isBuying ? 'Куплено' : 'Продано'} ${amount.toStringAsFixed(4)} ${widget.crypto.symbol}',
        ),
        backgroundColor: _isBuying 
          ? const Color(0xFF02C076) 
          : const Color(0xFFF6465D),
      ),
    );
  }
}