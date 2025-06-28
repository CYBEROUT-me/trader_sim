class Achievement {
  final String title;
  final String description;
  bool isCompleted;
  final int reputationReward;

  Achievement(this.title, this.description, this.isCompleted, this.reputationReward);

  void complete() {
    isCompleted = true;
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'isCompleted': isCompleted,
  };

  void fromJson(Map<String, dynamic> json) {
    isCompleted = json['isCompleted'] ?? false;
  }
}