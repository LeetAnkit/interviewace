class AnalysisResult {
  final bool success;
  final double overallScore;
  final Map<String, dynamic> detailedFeedback;
  final String followUpQuestion;
  final List<String> improvementSuggestions;
  final String timestamp;

  AnalysisResult({
    required this.success,
    required this.overallScore,
    required this.detailedFeedback,
    required this.followUpQuestion,
    required this.improvementSuggestions,
    required this.timestamp,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      success: json['success'] ?? false,
      overallScore: (json['overall_score'] ?? 0.0).toDouble(),
      detailedFeedback: json['detailed_feedback'] ?? {},
      followUpQuestion: json['follow_up_question'] ?? '',
      improvementSuggestions: List<String>.from(json['improvement_suggestions'] ?? []),
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'overall_score': overallScore,
      'detailed_feedback': detailedFeedback,
      'follow_up_question': followUpQuestion,
      'improvement_suggestions': improvementSuggestions,
      'timestamp': timestamp,
    };
  }
}