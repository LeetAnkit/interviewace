class PracticeQuestion {
  final String id;
  final String question;
  final String category;
  final String difficulty;
  final int? estimatedTime;
  final String? tips;

  PracticeQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.difficulty,
    this.estimatedTime,
    this.tips,
  });

  factory PracticeQuestion.fromJson(Map<String, dynamic> json) {
    return PracticeQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      category: json['category'] ?? 'general',
      difficulty: json['difficulty'] ?? 'intermediate',
      estimatedTime: json['estimated_time'],
      tips: json['tips'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'difficulty': difficulty,
      'estimated_time': estimatedTime,
      'tips': tips,
    };
  }
}