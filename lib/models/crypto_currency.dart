class CryptoCurrency {
  final String symbol;
  final String name;
  double price;
  double holding = 0.0;
  List<double> priceHistory = [];

  CryptoCurrency(this.symbol, this.name, this.price);

  void updatePrice(double changePercent) {
    price *= (1 + changePercent);
    priceHistory.add(price);
    if (priceHistory.length > 100) {
      priceHistory.removeAt(0);
    }
  }

  double get changePercent {
    if (priceHistory.length < 2) return 0.0;
    double oldPrice = priceHistory[priceHistory.length - 2];
    return (price - oldPrice) / oldPrice * 100;
  }

  bool get isPositive => changePercent >= 0;

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'price': price,
    'holding': holding,
  };

  void fromJson(Map<String, dynamic> json) {
    price = json['price']?.toDouble() ?? price;
    holding = json['holding']?.toDouble() ?? 0.0;
  }
}