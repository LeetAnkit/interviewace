import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/audio_playback_controls.dart';
import './widgets/feedback_category_card.dart';
import './widgets/improvement_suggestions.dart';
import './widgets/session_actions_sheet.dart';

class AiFeedbackResults extends StatefulWidget {
  const AiFeedbackResults({super.key});

  @override
  State<AiFeedbackResults> createState() => _AiFeedbackResultsState();
}

class _AiFeedbackResultsState extends State<AiFeedbackResults>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;
  bool _isPlaying = false;
  double _playbackPosition = 0.0;
  final double _totalDuration = 45.0;
  bool _showTranscript = false;

  // Mock feedback data
  final Map<String, dynamic> feedbackData = {
    "sessionId": "session_001",
    "question":
        "Tell me about yourself and why you're interested in this position.",
    "overallScore": 7.5,
    "audioUrl": "https://example.com/audio/response.mp3",
    "transcript":
        "Um, well, I'm a software developer with like 3 years of experience. I've worked on various projects and, you know, I'm really passionate about technology. I think this position would be a great fit because, um, I love solving problems and working with teams.",
    "categories": [
      {
        "name": "Content Quality",
        "score": 8.0,
        "color": 0xFF27AE60,
        "summary":
            "Strong technical background mentioned with relevant experience",
        "details": [
          "✓ Clearly stated professional background",
          "✓ Mentioned relevant experience duration",
          "⚠ Could elaborate more on specific achievements",
          "⚠ Missing connection to company values"
        ],
        "examples": [
          "Good: 'software developer with 3 years of experience'",
          "Improve: Add specific project examples or technologies"
        ]
      },
      {
        "name": "Delivery & Tone",
        "score": 6.5,
        "color": 0xFFF39C12,
        "summary": "Conversational tone but lacks confidence in delivery",
        "details": [
          "✓ Friendly and approachable tone",
          "⚠ Hesitant delivery affects confidence perception",
          "⚠ Pace could be more consistent",
          "✗ Voice projection needs improvement"
        ],
        "examples": [
          "Good: Maintained conversational tone throughout",
          "Improve: Reduce hesitation, speak with more conviction"
        ]
      },
      {
        "name": "Grammar & Clarity",
        "score": 7.0,
        "color": 0xFF27AE60,
        "summary":
            "Generally clear communication with minor grammatical issues",
        "details": [
          "✓ Complete sentences and clear structure",
          "✓ Good vocabulary usage",
          "⚠ Some run-on sentences",
          "⚠ Minor grammatical inconsistencies"
        ],
        "examples": [
          "Good: Clear sentence structure in most parts",
          "Improve: Break down complex thoughts into shorter sentences"
        ]
      },
      {
        "name": "Filler Words",
        "score": 5.5,
        "color": 0xFFE74C3C,
        "summary":
            "Frequent use of filler words affects professional impression",
        "details": [
          "✗ 'Um' used 4 times",
          "✗ 'Like' used 2 times",
          "✗ 'You know' used 2 times",
          "⚠ Total filler words: 8 in 45 seconds"
        ],
        "examples": [
          "Replace: 'Um, well, I'm a...' → 'I'm a...'",
          "Replace: 'like 3 years' → '3 years'",
          "Replace: 'you know, I'm really' → 'I'm really'"
        ]
      }
    ],
    "improvements": [
      "Practice your opening statement to reduce hesitation and filler words",
      "Prepare specific examples of your achievements and projects",
      "Work on voice projection and speaking with more confidence",
      "Connect your experience directly to the company's needs",
      "Practice pausing instead of using filler words"
    ],
    "timestamp": "2024-01-15T10:30:00Z",
    "duration": "45 seconds"
  };

  @override
  void initState() {
    super.initState();
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: feedbackData["overallScore"] / 10.0,
    ).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _scoreAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return AppTheme.lightTheme.colorScheme.secondary;
    if (score >= 6.0) return const Color(0xFFF39C12);
    return AppTheme.lightTheme.colorScheme.error;
  }

  String _getScoreLabel(double score) {
    if (score >= 8.0) return "Excellent";
    if (score >= 7.0) return "Good";
    if (score >= 6.0) return "Fair";
    return "Needs Improvement";
  }

  void _showSessionActionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionActionsSheet(
        sessionData: feedbackData,
      ),
    );
  }

  Future<void> _onRefresh() async {
    // Simulate re-processing
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Feedback updated with latest AI analysis"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          "AI Feedback Results",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color:
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSessionActionsSheet,
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              size: 24,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Score Section
              _buildOverallScoreCard(isDark),
              SizedBox(height: 3.h),

              // Question Section
              _buildQuestionCard(isDark),
              SizedBox(height: 3.h),

              // Audio Playback Controls
              AudioPlaybackControls(
                isPlaying: _isPlaying,
                position: _playbackPosition,
                duration: _totalDuration,
                onPlayPause: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
                onSeek: (value) {
                  setState(() {
                    _playbackPosition = value;
                  });
                },
                onToggleTranscript: () {
                  setState(() {
                    _showTranscript = !_showTranscript;
                  });
                },
                showTranscript: _showTranscript,
                transcript: feedbackData["transcript"],
              ),
              SizedBox(height: 3.h),

              // Feedback Categories
              Text(
                "Detailed Analysis",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 2.h),

              ...(feedbackData["categories"] as List).map((category) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: FeedbackCategoryCard(
                    category: category as Map<String, dynamic>,
                  ),
                );
              }),

              SizedBox(height: 3.h),

              // Improvement Suggestions
              ImprovementSuggestions(
                suggestions: (feedbackData["improvements"] as List)
                    .map((item) => item as String)
                    .toList(),
              ),
              SizedBox(height: 4.h),

              // Action Buttons
              _buildActionButtons(isDark),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallScoreCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Overall Performance",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 3.h),

          // Circular Progress Indicator
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                final score = feedbackData["overallScore"] as double;
                final animatedValue = _scoreAnimation.value;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: CircularProgressIndicator(
                        value: animatedValue,
                        strokeWidth: 8,
                        backgroundColor: (isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight)
                            .withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(score),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (score * animatedValue).toStringAsFixed(1),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(score),
                              ),
                        ),
                        Text(
                          "/ 10.0",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight,
                                  ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 2.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: _getScoreColor(feedbackData["overallScore"])
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getScoreLabel(feedbackData["overallScore"]),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _getScoreColor(feedbackData["overallScore"]),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'quiz',
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                "Interview Question",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            feedbackData["question"],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                "Duration: ${feedbackData["duration"]}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/active-practice-session');
                },
                icon: CustomIconWidget(
                  iconName: 'refresh',
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text("Try Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/practice-session-setup');
                },
                icon: CustomIconWidget(
                  iconName: 'arrow_forward',
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  size: 20,
                ),
                label: const Text("Next Question"),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  // Share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Score image saved to gallery"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: CustomIconWidget(
                  iconName: 'share',
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                  size: 18,
                ),
                label: const Text("Share Score"),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  // PDF export functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("PDF report exported successfully"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: CustomIconWidget(
                  iconName: 'picture_as_pdf',
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                  size: 18,
                ),
                label: const Text("Export PDF"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
