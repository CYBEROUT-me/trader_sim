import 'package:flutter/material.dart';
import 'dart:math';
import '../models/crypto_currency.dart';
import '../models/game_state.dart';
import '../widgets/candlestick_chart.dart';
import '../widgets/trade_dialog.dart';

class CryptoDetailPage extends StatefulWidget {
  final CryptoCurrency crypto;
  final GameState gameState;

  const CryptoDetailPage({
    super.key,
    required this.crypto,
    required this.gameState,
  });

  @override
  State<CryptoDetailPage> createState() => _CryptoDetailPageState();
}

class _CryptoDetailPageState extends State<CryptoDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = '1H';
  final List<String> _timeframes = ['1M', '5M', '15M', '1H', '4H', '1D', '1W'];
  bool _showIndicators = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPriceHeader(),
          _buildTimeframeSelector(),
          _buildChart(),
          _buildIndicatorsBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderBookTab(),
                _buildTradesTab(),
                _buildNewsTab(),
                _buildAnalysisTab(),
              ],
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E2329),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Text(
            '${widget.crypto.symbol}/USDT',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.star_border, color: Colors.grey),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.grey),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPriceHeader() {
    final isPositive = widget.crypto.isPositive;
    final priceColor = isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D);

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E2329),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$${widget.crypto.price.toStringAsFixed(2)}',
            style: TextStyle(
              color: priceColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '≈ ₽${(widget.crypto.price * 75).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priceColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${widget.crypto.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: priceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('24h High', '\$${(widget.crypto.price * 1.05).toStringAsFixed(2)}'),
              _buildStatItem('24h Low', '\$${(widget.crypto.price * 0.95).toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatItem('24h Vol(${widget.crypto.symbol})', '${(widget.crypto.price * 1000).toStringAsFixed(0)}'),
              _buildStatItem('24h Vol(USDT)', '${(widget.crypto.price * 50000).toStringAsFixed(0)}M'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF1E2329),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _timeframes.length,
              itemBuilder: (context, index) {
                final timeframe = _timeframes[index];
                final isSelected = timeframe == _selectedTimeframe;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedTimeframe = timeframe),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF0B90B) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      timeframe,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(
              _showIndicators ? Icons.show_chart : Icons.trending_up,
              color: _showIndicators ? const Color(0xFFF0B90B) : Colors.grey,
            ),
            onPressed: () => setState(() => _showIndicators = !_showIndicators),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 300,
      color: const Color(0xFF0B0E11),
      child: CandlestickChart(
        crypto: widget.crypto,
        timeframe: _selectedTimeframe,
        showIndicators: _showIndicators,
      ),
    );
  }

  Widget _buildIndicatorsBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF1E2329),
      child: Row(
        children: [
          _buildIndicatorChip('MA', true),
          _buildIndicatorChip('EMA', false),
          _buildIndicatorChip('BOLL', false),
          _buildIndicatorChip('SAR', false),
          _buildIndicatorChip('AVL', false),
          _buildIndicatorChip('VOL', true),
          _buildIndicatorChip('MACD', false),
          const Spacer(),
          Icon(Icons.fullscreen, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildIndicatorChip(String name, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0B90B).withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? const Color(0xFFF0B90B) : Colors.grey,
          width: 1,
        ),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: isActive ? const Color(0xFFF0B90B) : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF1E2329),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFF0B90B),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFFF0B90B),
        tabs: const [
          Tab(text: 'Книга ордеров'),
          Tab(text: 'Сделки'),
          Tab(text: 'Новости'),
          Tab(text: 'Анализ'),
        ],
      ),
    );
  }

  Widget _buildOrderBookTab() {
    return Container(
      color: const Color(0xFF0B0E11),
      child: Column(
        children: [
          // Заголовки
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: Text('Цена(USDT)', style: TextStyle(color: Colors.grey, fontSize: 12))),
                Expanded(child: Text('Кол-во(${widget.crypto.symbol})', style: TextStyle(color: Colors.grey, fontSize: 12))),
                Expanded(child: Text('Итого', style: TextStyle(color: Colors.grey, fontSize: 12))),
              ],
            ),
          ),
          // Ордера на продажу (красные)
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                final price = widget.crypto.price * (1 + (index + 1) * 0.001);
                final amount = Random().nextDouble() * 10;
                return _buildOrderBookRow(price, amount, false);
              },
            ),
          ),
          // Спред
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '\$${widget.crypto.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: widget.crypto.isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Ордера на покупку (зеленые)
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                final price = widget.crypto.price * (1 - (index + 1) * 0.001);
                final amount = Random().nextDouble() * 10;
                return _buildOrderBookRow(price, amount, true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBookRow(double price, double amount, bool isBuy) {
    final color = isBuy ? const Color(0xFF02C076) : const Color(0xFFF6465D);
    final total = price * amount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              price.toStringAsFixed(2),
              style: TextStyle(color: color, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              amount.toStringAsFixed(4),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              total.toStringAsFixed(2),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradesTab() {
    return Container(
      color: const Color(0xFF0B0E11),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: Text('Время', style: TextStyle(color: Colors.grey, fontSize: 12))),
                Expanded(child: Text('Цена(USDT)', style: TextStyle(color: Colors.grey, fontSize: 12))),
                Expanded(child: Text('Кол-во(${widget.crypto.symbol})', style: TextStyle(color: Colors.grey, fontSize: 12))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                final isBuy = Random().nextBool();
                final price = widget.crypto.price * (1 + (Random().nextDouble() - 0.5) * 0.01);
                final amount = Random().nextDouble() * 5;
                final time = DateTime.now().subtract(Duration(minutes: index));

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          price.toStringAsFixed(2),
                          style: TextStyle(
                            color: isBuy ? const Color(0xFF02C076) : const Color(0xFFF6465D),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          amount.toStringAsFixed(4),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    final newsItems = [
      {'title': '🚀 Крупный инвестор купил ${widget.crypto.symbol}', 'impact': 'positive', 'time': '5 мин назад'},
      {'title': '📈 Технический анализ показывает рост', 'impact': 'positive', 'time': '15 мин назад'},
      {'title': '⚠️ Волатильность на рынке', 'impact': 'negative', 'time': '30 мин назад'},
      {'title': '💎 Новые партнерства объявлены', 'impact': 'positive', 'time': '1 час назад'},
      {'title': '📊 Обновление протокола', 'impact': 'neutral', 'time': '2 часа назад'},
    ];

    return Container(
      color: const Color(0xFF0B0E11),
      child: ListView.builder(
        itemCount: newsItems.length,
        itemBuilder: (context, index) {
          final news = newsItems[index];
          Color impactColor = Colors.grey;
          if (news['impact'] == 'positive') impactColor = const Color(0xFF02C076);
          if (news['impact'] == 'negative') impactColor = const Color(0xFFF6465D);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news['title']!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: impactColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      news['time']!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalysisTab() {
  return Container(
    color: const Color(0xFF0B0E11),
    padding: const EdgeInsets.all(16),
    child: SingleChildScrollView( // <--- добавлено
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Технический анализ',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAnalysisItem('RSI (14)', '67.5', 'Нейтрально', Colors.orange),
          _buildAnalysisItem('MACD', '+12.3', 'Покупка', const Color(0xFF02C076)),
          _buildAnalysisItem('MA (50)', '\$${(widget.crypto.price * 0.98).toStringAsFixed(2)}', 'Поддержка', const Color(0xFF02C076)),
          _buildAnalysisItem('Bollinger Bands', 'Середина', 'Консолидация', Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'Прогноз на 24 часа',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: const Color(0xFF02C076)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Бычий тренд', style: TextStyle(color: Color(0xFF02C076), fontWeight: FontWeight.bold)),
                    Text('Ожидается рост на 3-7%', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildAnalysisItem(String indicator, String value, String signal, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(indicator, style: const TextStyle(color: Colors.white)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(signal, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E2329),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showTradeDialog(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF02C076),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Купить',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showTradeDialog(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF6465D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Продать',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTradeDialog(bool isBuying) {
    showDialog(
      context: context,
      builder: (context) => TradeDialog(
        crypto: widget.crypto,
        gameState: widget.gameState,
      ),
    );
  }
}