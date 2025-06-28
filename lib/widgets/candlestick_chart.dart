import 'package:flutter/material.dart';
import 'dart:math';
import '../models/crypto_currency.dart';

class CandlestickChart extends StatefulWidget {
  final CryptoCurrency crypto;
  final String timeframe;
  final bool showIndicators;

  const CandlestickChart({
    super.key,
    required this.crypto,
    required this.timeframe,
    required this.showIndicators,
  });

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  List<Candlestick> candlesticks = [];
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  void initState() {
    super.initState();
    _generateCandlesticks();
  }

  @override
  void didUpdateWidget(CandlestickChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeframe != widget.timeframe) {
      _generateCandlesticks();
    }
  }

  void _generateCandlesticks() {
    final random = Random();
    candlesticks.clear();
    
    double currentPrice = widget.crypto.price;
    final int candleCount = _getCandleCount();
    
    for (int i = candleCount; i >= 0; i--) {
      final open = currentPrice;
      final change = (random.nextDouble() - 0.5) * currentPrice * 0.05; // ±2.5%
      final close = open + change;
      
      final high = max(open, close) + random.nextDouble() * currentPrice * 0.02;
      final low = min(open, close) - random.nextDouble() * currentPrice * 0.02;
      
      final volume = random.nextDouble() * 1000000;
      final timestamp = DateTime.now().subtract(Duration(minutes: i * _getMinutesPerCandle()));
      
      candlesticks.add(Candlestick(
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
        timestamp: timestamp,
      ));
      
      currentPrice = close;
    }
    
    candlesticks = candlesticks.reversed.toList();
  }

  int _getCandleCount() {
    switch (widget.timeframe) {
      case '1M': return 60;
      case '5M': return 48;
      case '15M': return 32;
      case '1H': return 24;
      case '4H': return 18;
      case '1D': return 30;
      case '1W': return 12;
      default: return 24;
    }
  }

  int _getMinutesPerCandle() {
    switch (widget.timeframe) {
      case '1M': return 1;
      case '5M': return 5;
      case '15M': return 15;
      case '1H': return 60;
      case '4H': return 240;
      case '1D': return 1440;
      case '1W': return 10080;
      default: return 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0E11),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onScaleStart: (details) {
                _previousScale = _scale;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _scale = _previousScale * details.scale;
                  _scale = _scale.clamp(0.5, 3.0);
                });
              },
              child: CustomPaint(
                painter: CandlestickPainter(
                  candlesticks: candlesticks,
                  showIndicators: widget.showIndicators,
                  scale: _scale,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          if (widget.showIndicators)
            Expanded(
              flex: 1,
              child: CustomPaint(
                painter: VolumePainter(candlesticks: candlesticks),
                size: Size.infinite,
              ),
            ),
        ],
      ),
    );
  }
}

class Candlestick {
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final DateTime timestamp;

  Candlestick({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.timestamp,
  });

  bool get isBullish => close > open;
  double get body => (close - open).abs();
  double get upperWick => high - max(open, close);
  double get lowerWick => min(open, close) - low;
}

class CandlestickPainter extends CustomPainter {
  final List<Candlestick> candlesticks;
  final bool showIndicators;
  final double scale;

  CandlestickPainter({
    required this.candlesticks,
    required this.showIndicators,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candlesticks.isEmpty) return;

    final bullishPaint = Paint()
      ..color = const Color(0xFF02C076)
      ..style = PaintingStyle.fill;

    final bearishPaint = Paint()
      ..color = const Color(0xFFF6465D)
      ..style = PaintingStyle.fill;

    final wickPaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    // Найти min/max для масштабирования
    final prices = candlesticks.expand((c) => [c.high, c.low]).toList();
    final minPrice = prices.reduce(min);
    final maxPrice = prices.reduce(max);
    final priceRange = maxPrice - minPrice;

    if (priceRange == 0) return;

    // Нарисовать сетку
    _drawGrid(canvas, size, gridPaint, minPrice, maxPrice, priceRange);

    // Ширина одной свечи
    final candleWidth = (size.width / candlesticks.length) * scale;
    final maxCandleWidth = candleWidth * 0.8;

    // Нарисовать скользящие средние
    if (showIndicators) {
      _drawMovingAverages(canvas, size, minPrice, priceRange, candleWidth);
    }

    // Нарисовать свечи
    for (int i = 0; i < candlesticks.length; i++) {
      final candle = candlesticks[i];
      final x = (i * candleWidth) + (candleWidth / 2);

      if (x > -candleWidth && x < size.width + candleWidth) {
        _drawCandle(canvas, size, candle, x, maxCandleWidth, 
                   minPrice, priceRange, bullishPaint, bearishPaint, wickPaint);
      }
    }

    // Нарисовать текущую цену
    _drawCurrentPrice(canvas, size, minPrice, priceRange);
  }

  void _drawGrid(Canvas canvas, Size size, Paint gridPaint, 
                double minPrice, double maxPrice, double priceRange) {
    // Горизонтальные линии
    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      
      // Подписи цен
      final price = maxPrice - (priceRange * i / 5);
      final textPainter = TextPainter(
        text: TextSpan(
          text: price.toStringAsFixed(2),
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - 60, y - 6));
    }

    // Вертикальные линии
    for (int i = 1; i < 5; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  void _drawMovingAverages(Canvas canvas, Size size, double minPrice, 
                          double priceRange, double candleWidth) {
    if (candlesticks.length < 20) return;

    final ma5Paint = Paint()
      ..color = const Color(0xFFF0B90B)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final ma10Paint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // MA5
    final ma5Path = Path();
    for (int i = 4; i < candlesticks.length; i++) {
      final ma5 = candlesticks.sublist(i - 4, i + 1)
          .map((c) => c.close)
          .reduce((a, b) => a + b) / 5;
      
      final x = (i * candleWidth) + (candleWidth / 2);
      final y = size.height - ((ma5 - minPrice) / priceRange) * size.height;
      
      if (i == 4) {
        ma5Path.moveTo(x, y);
      } else {
        ma5Path.lineTo(x, y);
      }
    }
    canvas.drawPath(ma5Path, ma5Paint);

    // MA10
    final ma10Path = Path();
    for (int i = 9; i < candlesticks.length; i++) {
      final ma10 = candlesticks.sublist(i - 9, i + 1)
          .map((c) => c.close)
          .reduce((a, b) => a + b) / 10;
      
      final x = (i * candleWidth) + (candleWidth / 2);
      final y = size.height - ((ma10 - minPrice) / priceRange) * size.height;
      
      if (i == 9) {
        ma10Path.moveTo(x, y);
      } else {
        ma10Path.lineTo(x, y);
      }
    }
    canvas.drawPath(ma10Path, ma10Paint);
  }

  void _drawCandle(Canvas canvas, Size size, Candlestick candle, double x,
                  double maxCandleWidth, double minPrice, double priceRange,
                  Paint bullishPaint, Paint bearishPaint, Paint wickPaint) {
    
    final openY = size.height - ((candle.open - minPrice) / priceRange) * size.height;
    final closeY = size.height - ((candle.close - minPrice) / priceRange) * size.height;
    final highY = size.height - ((candle.high - minPrice) / priceRange) * size.height;
    final lowY = size.height - ((candle.low - minPrice) / priceRange) * size.height;

    // Нарисовать фитиль
    wickPaint.color = candle.isBullish ? const Color(0xFF02C076) : const Color(0xFFF6465D);
    canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

    // Нарисовать тело свечи
    final bodyTop = min(openY, closeY);
    final bodyBottom = max(openY, closeY);
    final bodyHeight = bodyBottom - bodyTop;
    
    if (bodyHeight < 1) {
      // Дожи - горизонтальная линия
      canvas.drawLine(
        Offset(x - maxCandleWidth / 2, openY),
        Offset(x + maxCandleWidth / 2, openY),
        wickPaint,
      );
    } else {
      final rect = Rect.fromLTWH(
        x - maxCandleWidth / 2,
        bodyTop,
        maxCandleWidth,
        bodyHeight,
      );
      
      if (candle.isBullish) {
        canvas.drawRect(rect, bullishPaint);
      } else {
        canvas.drawRect(rect, bearishPaint);
      }
    }
  }

  void _drawCurrentPrice(Canvas canvas, Size size, double minPrice, double priceRange) {
    if (candlesticks.isEmpty) return;
    
    final currentPrice = candlesticks.last.close;
    final y = size.height - ((currentPrice - minPrice) / priceRange) * size.height;
    
    final pricePaint = Paint()
      ..color = candlesticks.last.isBullish ? const Color(0xFF02C076) : const Color(0xFFF6465D)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Горизонтальная линия
    final path = Path();
    path.moveTo(0, y);
    path.lineTo(size.width, y);
    
    // Пунктирная линия
    final dashWidth = 5.0;
    final dashSpace = 3.0;
    double distance = 0.0;
    final pathLength = size.width;
    
    while (distance < pathLength) {
      final endDistance = distance + dashWidth;
      
      if (endDistance > pathLength) break;
      
      canvas.drawLine(
        Offset(distance, y), 
        Offset(endDistance, y), 
        pricePaint
      );
      distance += dashWidth + dashSpace;
    }

    // Цена справа
    final textPainter = TextPainter(
      text: TextSpan(
        text: currentPrice.toStringAsFixed(2),
        style: TextStyle(
          color: candlesticks.last.isBullish ? const Color(0xFF02C076) : const Color(0xFFF6465D),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Фон для цены
    final bgRect = Rect.fromLTWH(
      size.width - textPainter.width - 8,
      y - textPainter.height / 2 - 4,
      textPainter.width + 8,
      textPainter.height + 8,
    );
    
    canvas.drawRect(bgRect, Paint()..color = (candlesticks.last.isBullish ? const Color(0xFF02C076) : const Color(0xFFF6465D)));
    textPainter.paint(canvas, Offset(size.width - textPainter.width - 4, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class VolumePainter extends CustomPainter {
  final List<Candlestick> candlesticks;

  VolumePainter({required this.candlesticks});

  @override
  void paint(Canvas canvas, Size size) {
    if (candlesticks.isEmpty) return;

    final maxVolume = candlesticks.map((c) => c.volume).reduce(max);
    final candleWidth = size.width / candlesticks.length;

    for (int i = 0; i < candlesticks.length; i++) {
      final candle = candlesticks[i];
      final x = i * candleWidth;
      final height = (candle.volume / maxVolume) * size.height;
      
      final paint = Paint()
        ..color = (candle.isBullish ? const Color(0xFF02C076) : const Color(0xFFF6465D)).withOpacity(0.6)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(x + candleWidth * 0.1, size.height - height, candleWidth * 0.8, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}