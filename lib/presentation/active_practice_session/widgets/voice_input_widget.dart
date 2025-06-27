import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceInputWidget extends StatelessWidget {
  final bool isRecording;
  final double recordingLevel;
  final Animation<double> recordingAnimation;
  final Animation<double> waveformAnimation;
  final VoidCallback onToggleRecording;

  const VoiceInputWidget({
    super.key,
    required this.isRecording,
    required this.recordingLevel,
    required this.recordingAnimation,
    required this.waveformAnimation,
    required this.onToggleRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Recording status text
        Text(
          isRecording ? 'Recording...' : 'Tap to start recording',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: isRecording
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),

        SizedBox(height: 4.h),

        // Microphone button with animation
        GestureDetector(
          onTap: onToggleRecording,
          child: AnimatedBuilder(
            animation: recordingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isRecording ? recordingAnimation.value : 1.0,
                child: Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (isRecording
                                ? AppTheme.lightTheme.colorScheme.error
                                : AppTheme.lightTheme.colorScheme.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: isRecording ? 20 : 8,
                        spreadRadius: isRecording ? 4 : 0,
                      ),
                    ],
                  ),
                  child: CustomIconWidget(
                    iconName: isRecording ? 'stop' : 'mic',
                    color: Colors.white,
                    size: 10.w,
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 4.h),

        // Waveform visualization
        if (isRecording)
          SizedBox(
            height: 8.h,
            width: 80.w,
            child: AnimatedBuilder(
              animation: waveformAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: WaveformPainter(
                    level: recordingLevel,
                    animation: waveformAnimation.value,
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                  size: Size(80.w, 8.h),
                );
              },
            ),
          ),

        // Recording level indicator
        if (isRecording) ...[
          SizedBox(height: 2.h),
          Container(
            width: 60.w,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: recordingLevel,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double level;
  final double animation;
  final Color color;

  WaveformPainter({
    required this.level,
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = size.width / 20;

    for (int i = 0; i < 20; i++) {
      final x = i * barWidth + barWidth / 2;
      final heightMultiplier =
          (level * (0.5 + 0.5 * (i % 3 + 1) / 3)) * animation;
      final barHeight = size.height * 0.3 * heightMultiplier;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
