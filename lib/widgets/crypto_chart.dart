import 'package:flutter/material.dart';
import 'dart:math';
import '../models/crypto_currency.dart';

class CryptoChart extends StatelessWidget {
  final CryptoCurrency crypto;
  final double height;

  const CryptoChart({
    super.key,
    required this.crypto,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (crypto.priceHistory.length < 2) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'Недостаточно данных для графика',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${crypto.symbol} График',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${crypto.price.toStringAsFixed(crypto.price > 1 ? 2 : 6)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: crypto.isPositive 
                    ? const Color(0xFF02C076) 
                    : const Color(0xFFF6465D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              painter: ChartPainter(
                prices: crypto.priceHistory,
                isPositive: crypto.isPositive,
              ),
              size: Size.infinite,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Мин: \$${_getMinPrice().toStringAsFixed(crypto.price > 1 ? 2 : 6)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                'Макс: \$${_getMaxPrice().toStringAsFixed(crypto.price > 1 ? 2 : 6)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getMinPrice() {
    if (crypto.priceHistory.isEmpty) return 0;
    return crypto.priceHistory.reduce(min);
  }

  double _getMaxPrice() {
    if (crypto.priceHistory.isEmpty) return 0;
    return crypto.priceHistory.reduce(max);
  }
}

class ChartPainter extends CustomPainter {
  final List<double> prices;
  final bool isPositive;

  ChartPainter({required this.prices, required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final paint = Paint()
      ..color = isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = (isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D))
          .withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Найти минимальное и максимальное значения
    final minPrice = prices.reduce(min);
    final maxPrice = prices.reduce(max);
    final priceRange = maxPrice - minPrice;

    if (priceRange == 0) return;

    // Рисуем сетку
    _drawGrid(canvas, size, gridPaint);

    // Создаем путь для линии
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < prices.length; i++) {
      final x = (i / (prices.length - 1)) * size.width;
      final y = size.height - ((prices[i] - minPrice) / priceRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Замыкаем путь заливки
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Рисуем заливку
    canvas.drawPath(fillPath, fillPaint);

    // Рисуем линию
    canvas.drawPath(path, paint);

    // Рисуем точки
    final pointPaint = Paint()
      ..color = isPositive ? const Color(0xFF02C076) : const Color(0xFFF6465D)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < prices.length; i++) {
      if (i % 5 == 0 || i == prices.length - 1) { // Показываем каждую 5-ю точку
        final x = (i / (prices.length - 1)) * size.width;
        final y = size.height - ((prices[i] - minPrice) / priceRange) * size.height;
        canvas.drawCircle(Offset(x, y), 3, pointPaint);
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint gridPaint) {
    // Горизонтальные линии
    for (int i = 1; i < 5; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Вертикальные линии
    for (int i = 1; i < 5; i++) {
      final x = (size.width / 5) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Диалог с детальным графиком
class CryptoChartDialog extends StatelessWidget {
  final CryptoCurrency crypto;

  const CryptoChartDialog({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E2329),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${crypto.symbol} - ${crypto.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CryptoChart(crypto: crypto, height: 300),
            ),
            const SizedBox(height: 16),
            _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
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
              const Text('Текущая цена:'),
              Text(
                '\$${crypto.price.toStringAsFixed(crypto.price > 1 ? 2 : 6)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Изменение:'),
              Text(
                '${crypto.isPositive ? '+' : ''}${crypto.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: crypto.isPositive 
                    ? const Color(0xFF02C076) 
                    : const Color(0xFFF6465D),
                ),
              ),
            ],
          ),
          if (crypto.holding > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ваши позиции:'),
                Text(
                  '${crypto.holding.toStringAsFixed(4)} ${crypto.symbol}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF0B90B),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Стоимость позиций:'),
                Text(
                  '\$${(crypto.holding * crypto.price).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02C076),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}