class GameNews {
  final String text;
  final NewsImpact impact;
  final String affectedCrypto;
  bool isActive = false;
  int activeTicks = 0;

  GameNews(this.text, this.impact, this.affectedCrypto);

  void activate() {
    isActive = true;
    activeTicks = 0;
  }

  void tick() {
    if (isActive) {
      activeTicks++;
      if (activeTicks > 20) {
        isActive = false;
      }
    }
  }
}

enum NewsImpact { positive, negative }