import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';
import '../models/practice_question.dart';
import '../models/session.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000'; // Change for production
  
  // Transcribe audio file
  Future<String> transcribeAudio(File audioFile, {String? userId}) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/transcribe'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('audio', audioFile.path),
      );
      
      if (userId != null) {
        request.fields['user_id'] = userId;
      }
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data['transcription'] ?? '';
      } else {
        throw Exception('Failed to transcribe audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Transcription error: $e');
    }
  }
  
  // Analyze interview response
  Future<AnalysisResult> analyzeResponse({
    required String text,
    String? question,
    String? userId,
    String category = 'general',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
          'question': question,
          'user_id': userId,
          'category': category,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AnalysisResult.fromJson(data);
      } else {
        throw Exception('Failed to analyze response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Analysis error: $e');
    }
  }
  
  // Get practice questions
  Future<List<PracticeQuestion>> getPracticeQuestions({
    String category = 'general',
    String difficulty = 'intermediate',
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/questions?category=$category&difficulty=$difficulty&limit=$limit'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final questions = data['questions'] as List;
        return questions.map((q) => PracticeQuestion.fromJson(q)).toList();
      } else {
        throw Exception('Failed to get questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Questions error: $e');
    }
  }
  
  // Get user sessions
  Future<List<Session>> getUserSessions({
    required String userId,
    int limit = 20,
    String? startDate,
    String? endDate,
  }) async {
    try {
      String url = '$baseUrl/sessions?user_id=$userId&limit=$limit';
      if (startDate != null) url += '&start_date=$startDate';
      if (endDate != null) url += '&end_date=$endDate';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sessions = data['sessions'] as List;
        return sessions.map((s) => Session.fromJson(s)).toList();
      } else {
        throw Exception('Failed to get sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Sessions error: $e');
    }
  }
  
  // Get user statistics
  Future<Map<String, dynamic>> getUserStats({
    required String userId,
    String period = 'month',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats?user_id=$userId&period=$period'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['stats'];
      } else {
        throw Exception('Failed to get stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Stats error: $e');
    }
  }
}