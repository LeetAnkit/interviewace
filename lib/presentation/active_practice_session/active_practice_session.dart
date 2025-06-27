import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/audio_playback_widget.dart';
import './widgets/exit_confirmation_dialog.dart';
import './widgets/network_status_widget.dart';
import './widgets/question_display_widget.dart';
import './widgets/recording_controls_widget.dart';
import './widgets/session_controls_widget.dart';
import './widgets/text_input_widget.dart';
import './widgets/thinking_time_widget.dart';
import './widgets/timer_widget.dart';
import './widgets/voice_input_widget.dart';

class ActivePracticeSession extends StatefulWidget {
  const ActivePracticeSession({super.key});

  @override
  State<ActivePracticeSession> createState() => _ActivePracticeSessionState();
}

class _ActivePracticeSessionState extends State<ActivePracticeSession>
    with TickerProviderStateMixin {
  // Mock data for the practice session
  final Map<String, dynamic> sessionData = {
    "sessionId": "session_001",
    "currentQuestion": {
      "id": 1,
      "text":
          "Tell me about yourself and why you're interested in this position.",
      "category": "General",
      "difficulty": "Easy",
      "timeLimit": 180
    },
    "totalQuestions": 5,
    "currentQuestionIndex": 1,
    "isTimerEnabled": true,
    "sessionType": "voice", // voice or text
    "settings": {
      "thinkingTimeEnabled": true,
      "autoSaveEnabled": true,
      "hapticFeedbackEnabled": true
    }
  };

  // State variables
  bool _isRecording = false;
  bool _isPaused = false;
  bool _hasRecording = false;
  bool _isPlayingBack = false;
  bool _isThinkingTime = false;
  bool _isTextMode = false;
  bool _hasResponse = false;
  final bool _isNetworkConnected = true;
  int _remainingTime = 180;
  int _thinkingTimeRemaining = 30;
  String _textResponse = '';
  String _transcribedText = '';
  double _recordingLevel = 0.0;
  double _playbackProgress = 0.0;

  // Controllers
  late AnimationController _recordingAnimationController;
  late AnimationController _waveformAnimationController;
  late Animation<double> _recordingPulseAnimation;
  late Animation<double> _waveformAnimation;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startTimer();
    _checkInputMode();
  }

  void _initializeAnimations() {
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveformAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _recordingPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _recordingAnimationController,
      curve: Curves.easeInOut,
    ));

    _waveformAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_waveformAnimationController);

    _recordingAnimationController.repeat(reverse: true);
  }

  void _checkInputMode() {
    final sessionType = sessionData["sessionType"] as String;
    setState(() {
      _isTextMode = sessionType == "text";
    });
  }

  void _startTimer() {
    if (sessionData["isTimerEnabled"] == true) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _remainingTime > 0 && !_isThinkingTime) {
          setState(() {
            _remainingTime--;
          });
          _startTimer();
        }
      });
    }
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _hasRecording = true;
      _hasResponse = true;
    });

    if (sessionData["settings"]["hapticFeedbackEnabled"] == true) {
      HapticFeedback.lightImpact();
    }

    _simulateRecordingLevel();
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _recordingLevel = 0.0;
    });

    if (sessionData["settings"]["hapticFeedbackEnabled"] == true) {
      HapticFeedback.lightImpact();
    }

    _simulateTranscription();
  }

  void _pauseRecording() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _simulateRecordingLevel() {
    if (_isRecording && !_isPaused) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _isRecording && !_isPaused) {
          setState(() {
            _recordingLevel = (0.2 +
                (0.8 *
                    (0.5 +
                        0.5 *
                            (DateTime.now().millisecondsSinceEpoch % 1000) /
                            1000)));
          });
          _waveformAnimationController.forward().then((_) {
            _waveformAnimationController.reverse();
          });
          _simulateRecordingLevel();
        }
      });
    }
  }

  void _simulateTranscription() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _transcribedText =
              "I am a dedicated software engineer with 5 years of experience in mobile app development. I'm particularly interested in this position because it aligns with my passion for creating user-friendly applications.";
        });
      }
    });
  }

  void _togglePlayback() {
    setState(() {
      _isPlayingBack = !_isPlayingBack;
    });

    if (_isPlayingBack) {
      _simulatePlayback();
    }
  }

  void _simulatePlayback() {
    if (_isPlayingBack) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _isPlayingBack) {
          setState(() {
            _playbackProgress += 0.01;
            if (_playbackProgress >= 1.0) {
              _playbackProgress = 1.0;
              _isPlayingBack = false;
            }
          });
          if (_isPlayingBack) {
            _simulatePlayback();
          }
        }
      });
    }
  }

  void _activateThinkingTime() {
    setState(() {
      _isThinkingTime = true;
      _thinkingTimeRemaining = 30;
    });

    _startThinkingTimer();
  }

  void _startThinkingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _thinkingTimeRemaining > 0 && _isThinkingTime) {
        setState(() {
          _thinkingTimeRemaining--;
        });
        if (_thinkingTimeRemaining > 0) {
          _startThinkingTimer();
        } else {
          setState(() {
            _isThinkingTime = false;
          });
        }
      }
    });
  }

  void _onTextChanged(String value) {
    setState(() {
      _textResponse = value;
      _hasResponse = value.trim().isNotEmpty;
    });
  }

  void _submitAnswer() {
    if (_hasResponse) {
      Navigator.pushNamed(context, '/ai-feedback-results');
    }
  }

  void _skipQuestion() {
    _showSkipConfirmation();
  }

  void _showSkipConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Skip Question',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to skip this question? You won\'t be able to return to it.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _moveToNextQuestion();
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  void _moveToNextQuestion() {
    // Simulate moving to next question or ending session
    Navigator.pushNamed(context, '/ai-feedback-results');
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ExitConfirmationDialog(
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _recordingAnimationController.dispose();
    _waveformAnimationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Network status indicator
              NetworkStatusWidget(
                isConnected: _isNetworkConnected,
              ),

              // Question display
              Expanded(
                flex: 2,
                child: QuestionDisplayWidget(
                  question: sessionData["currentQuestion"]["text"] as String,
                  questionNumber: sessionData["currentQuestionIndex"] as int,
                  totalQuestions: sessionData["totalQuestions"] as int,
                  category:
                      sessionData["currentQuestion"]["category"] as String,
                ),
              ),

              // Timer
              if (sessionData["isTimerEnabled"] == true)
                TimerWidget(
                  remainingTime: _remainingTime,
                  totalTime: sessionData["currentQuestion"]["timeLimit"] as int,
                  isThinkingTime: _isThinkingTime,
                  thinkingTimeRemaining: _thinkingTimeRemaining,
                ),

              // Input area
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: _isTextMode
                      ? _buildTextInputArea()
                      : _buildVoiceInputArea(),
                ),
              ),

              // Controls area
              Container(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    // Thinking time button
                    if (sessionData["settings"]["thinkingTimeEnabled"] ==
                            true &&
                        !_isThinkingTime)
                      ThinkingTimeWidget(
                        onActivate: _activateThinkingTime,
                        isEnabled: !_isRecording,
                      ),

                    SizedBox(height: 2.h),

                    // Session controls
                    SessionControlsWidget(
                      hasResponse: _hasResponse,
                      onSubmit: _submitAnswer,
                      onSkip: _skipQuestion,
                      isRecording: _isRecording,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceInputArea() {
    return Column(
      children: [
        // Voice input widget
        Expanded(
          flex: 3,
          child: VoiceInputWidget(
            isRecording: _isRecording,
            recordingLevel: _recordingLevel,
            recordingAnimation: _recordingPulseAnimation,
            waveformAnimation: _waveformAnimation,
            onToggleRecording: _toggleRecording,
          ),
        ),

        SizedBox(height: 2.h),

        // Recording controls
        if (_hasRecording)
          RecordingControlsWidget(
            isRecording: _isRecording,
            isPaused: _isPaused,
            onPause: _pauseRecording,
            onStop: _stopRecording,
            onPlayback: _togglePlayback,
            isPlayingBack: _isPlayingBack,
          ),

        SizedBox(height: 2.h),

        // Audio playback
        if (_hasRecording && !_isRecording)
          AudioPlaybackWidget(
            progress: _playbackProgress,
            isPlaying: _isPlayingBack,
            onSeek: (value) {
              setState(() {
                _playbackProgress = value;
              });
            },
            onTogglePlayback: _togglePlayback,
          ),

        // Transcribed text
        if (_transcribedText.isNotEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 2.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transcription:',
                  style: AppTheme.lightTheme.textTheme.labelMedium,
                ),
                SizedBox(height: 1.h),
                Text(
                  _transcribedText,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTextInputArea() {
    return Column(
      children: [
        Expanded(
          child: TextInputWidget(
            controller: _textController,
            onChanged: _onTextChanged,
            maxLength: 1000,
          ),
        ),
      ],
    );
  }
}
