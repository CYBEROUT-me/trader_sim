class MiningRig {
  final MiningRigType type;
  
  MiningRig(this.type);
  
  double get minePerSecond => type.hashrate / 1000000;

  Map<String, dynamic> toJson() => {
    'typeName': type.name,
  };
}

class MiningRigType {
  final String name;
  final double price;
  final double hashrate;
  final String description;

  const MiningRigType(this.name, this.price, this.hashrate, this.description);

  static const List<MiningRigType> available = [
    MiningRigType('CPU Miner', 100, 1000, 'Слабый, но дешевый'),
    MiningRigType('GPU RTX 3060', 500, 5000, 'Хорошая видеокарта'),
    MiningRigType('GPU RTX 4090', 2000, 25000, 'Топовая видеокарта'),
    MiningRigType('ASIC S19', 5000, 100000, 'Профессиональное оборудование'),
  ];
}