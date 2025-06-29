import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../models/crypto_currency.dart';
import '../widgets/crypto_tile.dart';
import '../widgets/trade_dialog.dart';

class TradingPage extends StatefulWidget {
  final GameState gameState;

  const TradingPage({super.key, required this.gameState});

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage> 
    with TickerProviderStateMixin {
  
  String _sortBy = 'symbol'; // symbol, price, change, holding
  bool _ascending = true;
  String _searchQuery = '';
  late AnimationController _refreshController;
  
  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Рекламный блок
        _buildAdBanner(),
        
        // Поиск и сортировка
        _buildSearchAndSort(),
        
        // Быстрая статистика
        _buildQuickStats(),
        
        // Список криптовалют
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFFF0B90B),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _getFilteredCryptos().length,
              itemBuilder: (context, index) {
                final crypto = _getFilteredCryptos()[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 100 + (index * 50)),
                  curve: Curves.easeOutBack,
                  child: CryptoTile(
                    crypto: crypto,
                    gameState: widget.gameState,
                    onTap: () => _showTradeDialog(context, crypto),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Нижняя панель с быстрыми действиями
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildAdBanner() {
  return Container(
    margin: const EdgeInsets.all(8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFFF0B90B).withOpacity(0.1),
          const Color(0xFF02C076).withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFF0B90B).withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '🚀 Премиум стратегии',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF0B90B),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Увеличь прибыль на 200%!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎁 Получен бонус +50\$ за просмотр рекламы!'),
                backgroundColor: Color(0xFF02C076),
              ),
            );
            widget.gameState.balance += 50;
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF0B90B),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: const Text(
            'ОТКРЫТЬ',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildSearchAndSort() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Поиск
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск криптовалют...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFF1E2329),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // Сортировка
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2329),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, color: Color(0xFFF0B90B)),
                  const SizedBox(width: 4),
                  Icon(
                    _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: const Color(0xFFF0B90B),
                  ),
                ],
              ),
            ),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _ascending = !_ascending;
                } else {
                  _sortBy = value;
                  _ascending = true;
                }
              });
              HapticFeedback.selectionClick();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'symbol', child: Text('По символу')),
              const PopupMenuItem(value: 'price', child: Text('По цене')),
              const PopupMenuItem(value: 'change', child: Text('По изменению')),
              const PopupMenuItem(value: 'holding', child: Text('По позициям')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalPortfolio = widget.gameState.cryptos.fold<double>(
      0.0, (sum, crypto) => sum + (crypto.holding * crypto.price),
    );
    
    final positiveCount = widget.gameState.cryptos.where((c) => c.isPositive).length;
    final negativeCount = widget.gameState.cryptos.length - positiveCount;

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Портфель',
              '\$${totalPortfolio.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              const Color(0xFFF0B90B),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Растут',
              '$positiveCount',
              Icons.trending_up,
              const Color(0xFF02C076),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Падают',
              '$negativeCount',
              Icons.trending_down,
              const Color(0xFFF6465D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2329),
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _quickBuyTop(),
                icon: const Icon(Icons.trending_up, size: 16),
                label: const Text('Купить лидера'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02C076),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _sellAll(),
                icon: const Icon(Icons.sell, size: 16),
                label: const Text('Продать всё'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF6465D),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0B90B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () => _autoTrade(),
                icon: const Icon(Icons.smart_toy, color: Colors.black),
                tooltip: 'Авто-торговля',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CryptoCurrency> _getFilteredCryptos() {
    var filtered = widget.gameState.cryptos.where((crypto) {
      return crypto.symbol.toLowerCase().contains(_searchQuery) ||
             crypto.name.toLowerCase().contains(_searchQuery);
    }).toList();

    filtered.sort((a, b) {
      int result;
      switch (_sortBy) {
        case 'price':
          result = a.price.compareTo(b.price);
          break;
        case 'change':
          result = a.changePercent.compareTo(b.changePercent);
          break;
        case 'holding':
          result = a.holding.compareTo(b.holding);
          break;
        default:
          result = a.symbol.compareTo(b.symbol);
      }
      return _ascending ? result : -result;
    });

    return filtered;
  }

  Future<void> _refreshData() async {
    _refreshController.forward();
    await Future.delayed(const Duration(seconds: 1));
    _refreshController.reverse();
    
    // Показать уведомление
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📊 Данные обновлены!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _showTradeDialog(BuildContext context, CryptoCurrency crypto) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => TradeDialog(crypto: crypto, gameState: widget.gameState),
    );
  }

  void _quickBuyTop() {
    final topCrypto = widget.gameState.cryptos
        .where((c) => c.changePercent > 0)
        .toList()
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    
    if (topCrypto.isNotEmpty) {
      final crypto = topCrypto.first;
      final amount = 100 / crypto.price; // Купить на $100
      widget.gameState.buyCrypto(crypto, amount);
      
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚀 Куплен лидер роста: ${crypto.symbol}!'),
          backgroundColor: const Color(0xFF02C076),
        ),
      );
    }
  }

  void _sellAll() {
    bool hasSales = false;
    for (final crypto in widget.gameState.cryptos) {
      if (crypto.holding > 0) {
        widget.gameState.sellCrypto(crypto, crypto.holding);
        hasSales = true;
      }
    }
    
    if (hasSales) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💰 Все позиции проданы!'),
          backgroundColor: Color(0xFFF6465D),
        ),
      );
    }
  }

  void _autoTrade() {
    // Простая логика авто-торговли
    for (final crypto in widget.gameState.cryptos) {
      if (crypto.changePercent > 5 && crypto.holding == 0) {
        // Купить растущие
        final amount = 50 / crypto.price;
        widget.gameState.buyCrypto(crypto, amount);
      } else if (crypto.changePercent < -3 && crypto.holding > 0) {
        // Продать падающие
        widget.gameState.sellCrypto(crypto, crypto.holding);
      }
    }
    
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🤖 Авто-торговля выполнена!'),
        backgroundColor: Color(0xFFF0B90B),
      ),
    );
  }
}