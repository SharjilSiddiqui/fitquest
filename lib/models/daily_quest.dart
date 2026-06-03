class DailyQuest {
  final String title;
  final int target;
  final int rewardXp;
  final int progress;

  const DailyQuest({
    required this.title,
    required this.target,
    required this.rewardXp,
    required this.progress,
  });

  bool get completed => progress >= target;

  DailyQuest copyWith({int? progress}) {
    return DailyQuest(
      title: title,
      target: target,
      rewardXp: rewardXp,
      progress: progress ?? this.progress,
    );
  }
}
