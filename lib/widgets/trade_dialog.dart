import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/crypto_currency.dart';
import '../models/game_state.dart';

class TradeDialog extends StatefulWidget {
  final CryptoCurrency crypto;
  final GameState gameState;

  const TradeDialog({super.key, required this.crypto, required this.gameState});

  @override
  State<TradeDialog> createState() => _TradeDialogState();
}

class _TradeDialogState extends State<TradeDialog> 
    with TickerProviderStateMixin {
  final _amountController = TextEditingController(text: '1.0');
  final _usdController = TextEditingController();
  bool _isBuying = true;
  bool _isAmountMode = true; // true = по количеству, false = по USD
  String? _errorMessage;
  
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    _amountController.addListener(_updateCalculations);
    _usdController.addListener(_updateCalculations);
    _updateCalculations();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _usdController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    setState(() {
      _errorMessage = null;
      
      if (_isAmountMode && _amountController.text.isNotEmpty) {
        final amount = double.tryParse(_amountController.text) ?? 0.0;
        final usdValue = amount * widget.crypto.price;
        _usdController.text = usdValue.toStringAsFixed(2);
      } else if (!_isAmountMode && _usdController.text.isNotEmpty) {
        final usdValue = double.tryParse(_usdController.text) ?? 0.0;
        final amount = usdValue / widget.crypto.price;
        _amountController.text = amount.toStringAsFixed(6);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2329),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isBuying ? const Color(0xFF02C076) : const Color(0xFFF6465D),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildContent(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (_isBuying ? const Color(0xFF02C076) : const Color(0xFFF6465D)).withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isBuying ? const Color(0xFF02C076) : const Color(0xFFF6465D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isBuying ? Icons.trending_up : Icons.trending_down,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_isBuying ? 'Купить' : 'Продать'} ${widget.crypto.symbol}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.crypto.name,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Информация о цене и балансе
          _buildInfoSection(),
          const SizedBox(height: 16),
          
          // Переключатель режима ввода
          _buildInputModeToggle(),
          const SizedBox(height: 12),
          
          // Поля ввода
          _buildInputFields(),
          const SizedBox(height: 16),
          
          // Быстрые кнопки
          _buildQuickButtons(),
          const SizedBox(height: 16),
          
          // Итоговая информация
          _buildSummary(),
          
          // Ошибка
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF6465D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF6465D)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Color(0xFFF6465D), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFF6465D), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final tradingBonus = widget.gameState.traderStatus.tradingBonus;
    
    return Container(
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
              const Text('Цена:', style: TextStyle(color: Colors.grey)),
              Text(
                '\$${widget.crypto.price.toStringAsFixed(widget.crypto.price > 1 ? 2 : 6)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ваш баланс:', style: TextStyle(color: Colors.grey)),
              Text(
                '\$${widget.gameState.balance.toStringAsFixed(2)}',
                style: const TextStyle(color: Color(0xFF02C076), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (widget.crypto.holding > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('У вас есть:', style: TextStyle(color: Colors.grey)),
                Text(
                  '${widget.crypto.holding.toStringAsFixed(4)} ${widget.crypto.symbol}',
                  style: const TextStyle(color: Color(0xFFF0B90B), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_isBuying ? "Скидка" : "Бонус"} статуса:',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                '${((tradingBonus - 1) * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Color(0xFF02C076), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E11),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAmountMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _isAmountMode ? const Color(0xFFF0B90B) : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  'Количество',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isAmountMode ? Colors.black : Colors.grey,
                    fontWeight: _isAmountMode ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAmountMode = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !_isAmountMode ? const Color(0xFFF0B90B) : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  'Сумма USD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isAmountMode ? Colors.black : Colors.grey,
                    fontWeight: !_isAmountMode ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Количество ${widget.crypto.symbol}',
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(color: Colors.grey),
              enabled: _isAmountMode,
              fillColor: _isAmountMode ? null : Colors.grey.withOpacity(0.1),
              filled: !_isAmountMode,
            ),
            onChanged: (value) {
              if (_isAmountMode) _updateCalculations();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _usdController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Сумма USD',
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(color: Colors.grey),
              enabled: !_isAmountMode,
              fillColor: !_isAmountMode ? null : Colors.grey.withOpacity(0.1),
              filled: _isAmountMode,
            ),
            onChanged: (value) {
              if (!_isAmountMode) _updateCalculations();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButtons() {
    final maxBuy = widget.gameState.balance / widget.crypto.price;
    final maxSell = widget.crypto.holding;
    final percentages = [25, 50, 75, 100];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isBuying ? 'Быстрая покупка:' : 'Быстрая продажа:',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: percentages.map((percent) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: percent == 100 ? 0 : 4),
                child: ElevatedButton(
                  onPressed: () {
                    final maxAmount = _isBuying ? maxBuy : maxSell;
                    final amount = maxAmount * (percent / 100);
                    _amountController.text = amount.toStringAsFixed(6);
                    _updateCalculations();
                    HapticFeedback.selectionClick();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B0E11),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: Text(
                    '$percent%',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final basePrice = widget.crypto.price * amount;
    final tradingBonus = widget.gameState.traderStatus.tradingBonus;
    final finalPrice = _isBuying 
      ? basePrice * (2.0 - tradingBonus)
      : basePrice * tradingBonus;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E11),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isBuying ? const Color(0xFF02C076) : const Color(0xFFF6465D),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Базовая стоимость:', style: TextStyle(color: Colors.grey)),
              Text('\$${basePrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isBuying ? 'Со скидкой:' : 'С бонусом:',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                '\$${finalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isBuying ? const Color(0xFF02C076) : const Color(0xFFF6465D),
                ),
              ),
            ],
          ),
          if (_isBuying && finalPrice > widget.gameState.balance) ...[
            const SizedBox(height: 4),
            Text(
              'Недостаточно средств!',
              style: const TextStyle(color: Color(0xFFF6465D), fontSize: 12),
            ),
          ],
          if (!_isBuying && amount > widget.crypto.holding) ...[
            const SizedBox(height: 4),
            Text(
              'Недостаточно ${widget.crypto.symbol}!',
              style: const TextStyle(color: Color(0xFFF6465D), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Переключатель купить/продать
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isBuying ? _bounceAnimation.value : 1.0,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _isBuying = true);
                          _bounceController.forward().then((_) => _bounceController.reverse());
                          HapticFeedback.selectionClick();
                        },
                        icon: const Icon(Icons.trending_up, size: 16),
                        label: const Text('Купить'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isBuying ? const Color(0xFF02C076) : Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: !_isBuying ? _bounceAnimation.value : 1.0,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _isBuying = false);
                          _bounceController.forward().then((_) => _bounceController.reverse());
                          HapticFeedback.selectionClick();
                        },
                        icon: const Icon(Icons.trending_down, size: 16),
                        label: const Text('Продать'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_isBuying ? const Color(0xFFF6465D) : Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Кнопки действий
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canExecuteTrade() ? _executeTrade : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isBuying ? const Color(0xFF02C076) : const Color(0xFFF6465D),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _isBuying ? 'КУПИТЬ' : 'ПРОДАТЬ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canExecuteTrade() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return false;
    
    if (_isBuying) {
      final cost = amount * widget.crypto.price * (2.0 - widget.gameState.traderStatus.tradingBonus);
      return cost <= widget.gameState.balance;
    } else {
      return amount <= widget.crypto.holding;
    }
  }

  void _executeTrade() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    if (amount <= 0) {
      setState(() => _errorMessage = 'Введите корректное количество');
      return;
    }
    
    try {
      if (_isBuying) {
        widget.gameState.buyCrypto(widget.crypto, amount);
        HapticFeedback.heavyImpact();
      } else {
        widget.gameState.sellCrypto(widget.crypto, amount);
        HapticFeedback.mediumImpact();
      }
      
      Navigator.pop(context);
      
      // Показать уведомление об успешной сделке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                _isBuying ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_isBuying ? 'Куплено' : 'Продано'} ${amount.toStringAsFixed(4)} ${widget.crypto.symbol}',
                ),
              ),
            ],
          ),
          backgroundColor: _isBuying ? const Color(0xFF02C076) : const Color(0xFFF6465D),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка выполнения сделки: $e');
    }
  }
}