import 'package:flutter/foundation.dart';

class TopScoreStore {
  final ValueNotifier<int> topScoreNotifier = ValueNotifier<int>(0);

  void registerScore(int score) {
    if (score > topScoreNotifier.value) {
      topScoreNotifier.value = score;
    }
  }
}
