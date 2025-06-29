import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../models/practice_question.dart';
import '../models/analysis_result.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  PracticeQuestion? _currentQuestion;
  String _selectedCategory = 'general';
  String _selectedDifficulty = 'intermediate';
  bool _isLoading = false;
  bool _isRecording = false;
  String? _transcription;
  AnalysisResult? _analysisResult;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  void _loadQuestion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final questions = await apiService.getPracticeQuestions(
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
        limit: 1,
      );

      if (questions.isNotEmpty) {
        setState(() {
          _currentQuestion = questions.first;
        });
      }
    } catch (e) {
      // Use fallback question
      setState(() {
        _currentQuestion = PracticeQuestion(
          id: 'fallback_1',
          question: 'Tell me about yourself and your professional background.',
          category: 'general',
          difficulty: 'beginner',
        );
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _startRecording() async {
    final audioService = Provider.of<AudioService>(context, listen: false);
    
    try {
      final success = await audioService.startRecording();
      if (success) {
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  void _stopRecording() async {
    final audioService = Provider.of<AudioService>(context, listen: false);
    
    try {
      final path = await audioService.stopRecording();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        await _transcribeAudio(path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording: $e')),
      );
    }
  }

  Future<void> _transcribeAudio(String audioPath) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final transcription = await apiService.transcribeAudio(
        File(audioPath),
        userId: 'demo_user_123',
      );

      setState(() {
        _transcription = transcription;
        _textController.text = transcription;
      });

      await _analyzeResponse(transcription);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transcription failed: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _analyzeResponse(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.analyzeResponse(
        text: text,
        question: _currentQuestion?.question,
        userId: 'demo_user_123',
        category: _selectedCategory,
      );

      setState(() {
        _analysisResult = result;
      });

      // Navigate to results screen
      Navigator.pushNamed(
        context,
        '/results',
        arguments: {
          'question': _currentQuestion,
          'response': text,
          'analysis': result,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuestion,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Difficulty Selection
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'general', child: Text('General')),
                            DropdownMenuItem(value: 'behavioral', child: Text('Behavioral')),
                            DropdownMenuItem(value: 'technical', child: Text('Technical')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                            _loadQuestion();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDifficulty,
                          decoration: const InputDecoration(
                            labelText: 'Difficulty',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                            DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                            DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedDifficulty = value!;
                            });
                            _loadQuestion();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Question Card
                  if (_currentQuestion != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Chip(
                                  label: Text(_currentQuestion!.category),
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(_currentQuestion!.difficulty),
                                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentQuestion!.question,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            if (_currentQuestion!.tips != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.lightbulb, color: Colors.blue.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _currentQuestion!.tips!,
                                        style: TextStyle(color: Colors.blue.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Recording Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            _isRecording ? 'Recording...' : 'Tap to record your answer',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _isRecording ? _stopRecording : _startRecording,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Text Input Alternative
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Or type your answer:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _textController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Type your answer here...',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _analyzeResponse(_textController.text),
                              child: const Text('Analyze Response'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}