import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/category_chips_widget.dart';
import './widgets/difficulty_selector_widget.dart';
import './widgets/question_mode_toggle_widget.dart';
import './widgets/question_preview_widget.dart';
import './widgets/session_type_selector_widget.dart';
import './widgets/time_limit_toggle_widget.dart';

class PracticeSessionSetup extends StatefulWidget {
  const PracticeSessionSetup({super.key});

  @override
  State<PracticeSessionSetup> createState() => _PracticeSessionSetupState();
}

class _PracticeSessionSetupState extends State<PracticeSessionSetup> {
  // Session configuration state
  String selectedSessionType = 'Voice Recording';
  String selectedCategory = 'General';
  bool isTimeLimitEnabled = true;
  String selectedDifficulty = 'Beginner';
  bool isRandomQuestion = true;
  bool isLoading = false;
  String? selectedQuestionId;

  // Mock data for categories
  final List<Map<String, dynamic>> categories = [
    {"id": "general", "name": "General", "icon": "help_outline"},
    {"id": "technical", "name": "Technical", "icon": "code"},
    {"id": "behavioral", "name": "Behavioral", "icon": "psychology"},
    {"id": "industry", "name": "Industry-Specific", "icon": "business"}
  ];

  // Mock data for sample questions
  final Map<String, List<Map<String, dynamic>>> sampleQuestions = {
    "General": [
      {
        "id": "gen_1",
        "question": "Tell me about yourself and your professional background.",
        "difficulty": "Beginner",
        "estimatedTime": "2-3 minutes"
      },
      {
        "id": "gen_2",
        "question":
            "What are your greatest strengths and how do they apply to this role?",
        "difficulty": "Intermediate",
        "estimatedTime": "2-3 minutes"
      }
    ],
    "Technical": [
      {
        "id": "tech_1",
        "question": "Explain the difference between REST and GraphQL APIs.",
        "difficulty": "Intermediate",
        "estimatedTime": "3-4 minutes"
      },
      {
        "id": "tech_2",
        "question": "How would you optimize a slow-performing database query?",
        "difficulty": "Advanced",
        "estimatedTime": "4-5 minutes"
      }
    ],
    "Behavioral": [
      {
        "id": "beh_1",
        "question":
            "Describe a time when you had to work with a difficult team member.",
        "difficulty": "Intermediate",
        "estimatedTime": "3-4 minutes"
      },
      {
        "id": "beh_2",
        "question":
            "Tell me about a project where you had to learn something completely new.",
        "difficulty": "Beginner",
        "estimatedTime": "2-3 minutes"
      }
    ],
    "Industry-Specific": [
      {
        "id": "ind_1",
        "question":
            "How do you stay updated with the latest trends in your industry?",
        "difficulty": "Intermediate",
        "estimatedTime": "2-3 minutes"
      },
      {
        "id": "ind_2",
        "question":
            "What challenges do you see facing this industry in the next 5 years?",
        "difficulty": "Advanced",
        "estimatedTime": "4-5 minutes"
      }
    ]
  };

  bool get isValidConfiguration {
    return selectedSessionType.isNotEmpty &&
        selectedCategory.isNotEmpty &&
        selectedDifficulty.isNotEmpty;
  }

  Map<String, dynamic>? get currentSampleQuestion {
    final questions = sampleQuestions[selectedCategory] ?? [];
    if (questions.isEmpty) return null;

    final filteredQuestions =
        questions.where((q) => q["difficulty"] == selectedDifficulty).toList();

    return filteredQuestions.isNotEmpty
        ? filteredQuestions.first
        : questions.first;
  }

  void _onSessionTypeChanged(String type) {
    setState(() {
      selectedSessionType = type;
    });

    if (type == 'Voice Recording') {
      _checkMicrophonePermission();
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void _onTimeLimitToggled(bool enabled) {
    setState(() {
      isTimeLimitEnabled = enabled;
    });
  }

  void _onDifficultyChanged(String difficulty) {
    setState(() {
      selectedDifficulty = difficulty;
    });
  }

  void _onQuestionModeToggled(bool isRandom) {
    setState(() {
      isRandomQuestion = isRandom;
    });
  }

  void _checkMicrophonePermission() {
    // Mock permission check - in real app would use permission_handler
    // For now, just show a brief loading state
    setState(() {
      isLoading = true;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void _refreshSampleQuestion() {
    setState(() {
      // In real app, this would fetch a new random question
      // For now, just trigger a rebuild to show the same question
    });
  }

  void _startPracticeSession() {
    if (!isValidConfiguration) return;

    setState(() {
      isLoading = true;
    });

    // Mock session start delay
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        Navigator.pushNamed(context, '/active-practice-session');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and close button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'close',
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Practice',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w), // Balance the close button
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Session Type Selection
                    SessionTypeSelectorWidget(
                      selectedType: selectedSessionType,
                      onTypeChanged: _onSessionTypeChanged,
                    ),

                    SizedBox(height: 3.h),

                    // Category Selection
                    CategoryChipsWidget(
                      categories: categories,
                      selectedCategory: selectedCategory,
                      onCategoryChanged: _onCategoryChanged,
                    ),

                    SizedBox(height: 3.h),

                    // Time Limit Toggle
                    TimeLimitToggleWidget(
                      isEnabled: isTimeLimitEnabled,
                      onToggled: _onTimeLimitToggled,
                    ),

                    SizedBox(height: 3.h),

                    // Difficulty Selection
                    DifficultySelectorWidget(
                      selectedDifficulty: selectedDifficulty,
                      onDifficultyChanged: _onDifficultyChanged,
                    ),

                    SizedBox(height: 3.h),

                    // Question Mode Toggle
                    QuestionModeToggleWidget(
                      isRandomMode: isRandomQuestion,
                      onModeToggled: _onQuestionModeToggled,
                    ),

                    SizedBox(height: 3.h),

                    // Question Preview
                    if (currentSampleQuestion != null)
                      QuestionPreviewWidget(
                        question: currentSampleQuestion!,
                        onRefresh: _refreshSampleQuestion,
                      ),

                    SizedBox(height: 10.h), // Space for fixed button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Fixed bottom button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: isValidConfiguration && !isLoading
                  ? _startPracticeSession
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isValidConfiguration
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.12),
                foregroundColor: isValidConfiguration
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.38),
                elevation: isValidConfiguration ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'play_arrow',
                          size: 20,
                          color: isValidConfiguration
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.38),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Start Practice',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isValidConfiguration
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.38),
                              ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
