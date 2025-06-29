import 'analysis_result.dart';

class Session {
  final String id;
  final String userId;
  final String question;
  final String response;
  final String category;
  final AnalysisResult? analysis;
  final String timestamp;

  Session({
    required this.id,
    required this.userId,
    required this.question,
    required this.response,
    required this.category,
    this.analysis,
    required this.timestamp,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      question: json['question'] ?? '',
      response: json['response'] ?? '',
      category: json['category'] ?? 'general',
      analysis: json['analysis'] != null 
          ? AnalysisResult.fromJson(json['analysis'])
          : null,
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'question': question,
      'response': response,
      'category': category,
      'analysis': analysis?.toJson(),
      'timestamp': timestamp,
    };
  }
}