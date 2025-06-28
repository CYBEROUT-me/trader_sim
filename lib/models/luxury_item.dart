import 'package:flutter/material.dart';

class LuxuryItem {
  final String name;
  final String category;
  final double price;
  final int reputationBonus;
  final String description;
  final IconData icon;
  final Color color;

  const LuxuryItem(
    this.name,
    this.category,
    this.price,
    this.reputationBonus,
    this.description,
    this.icon,
    this.color,
  );

  static const List<LuxuryItem> items = [
    // Транспорт
    LuxuryItem('Toyota Camry', 'Транспорт', 25000, 50, 'Надежный седан для ежедневных поездок', Icons.directions_car, Colors.blue),
    LuxuryItem('BMW X5', 'Транспорт', 75000, 150, 'Премиальный кроссовер', Icons.directions_car, Colors.grey),
    LuxuryItem('Mercedes S-Class', 'Транспорт', 120000, 300, 'Флагманский седан', Icons.directions_car, Colors.black),
    LuxuryItem('Lamborghini Huracan', 'Транспорт', 250000, 800, 'Итальянский суперкар', Icons.directions_car, Colors.orange),
    LuxuryItem('Bugatti Chiron', 'Транспорт', 3000000, 5000, 'Гиперкар мечты', Icons.directions_car, Color(0xFFFFD700)),
    
    // Недвижимость
    LuxuryItem('Квартира-студия', 'Недвижимость', 50000, 100, 'Уютная квартира в центре', Icons.home, Colors.brown),
    LuxuryItem('Двухкомнатная квартира', 'Недвижимость', 150000, 250, 'Просторная квартира', Icons.home, Colors.green),
    LuxuryItem('Загородный дом', 'Недвижимость', 500000, 600, 'Дом с садом за городом', Icons.house, Colors.green),
    LuxuryItem('Пентхаус', 'Недвижимость', 2000000, 1500, 'Роскошный пентхаус с видом на город', Icons.apartment, Colors.purple),
    LuxuryItem('Частный остров', 'Недвижимость', 10000000, 8000, 'Собственный тропический остров', Icons.terrain, Colors.cyan),
    
    // Технологии
    LuxuryItem('iPhone Pro', 'Технологии', 1200, 20, 'Флагманский смартфон', Icons.phone_iphone, Colors.grey),
    LuxuryItem('MacBook Pro', 'Технологии', 3000, 50, 'Профессиональный ноутбук', Icons.laptop_mac, Colors.grey),
    LuxuryItem('Криптокошелек Ledger', 'Технологии', 500, 30, 'Безопасное хранение криптовалют', Icons.account_balance_wallet, Colors.black),
    LuxuryItem('Торговый терминал Bloomberg', 'Технологии', 25000, 200, 'Профессиональный торговый терминал', Icons.monitor, Colors.orange),
    
    // Роскошь
    LuxuryItem('Rolex Submariner', 'Роскошь', 15000, 300, 'Легендарные швейцарские часы', Icons.watch, Color(0xFFFFD700)),
    LuxuryItem('Частный самолет', 'Роскошь', 5000000, 3000, 'Личный реактивный самолет', Icons.flight, Colors.white),
    LuxuryItem('Яхта', 'Роскошь', 8000000, 4000, 'Роскошная яхта для морских путешествий', Icons.directions_boat, Colors.blue),
  ];
}