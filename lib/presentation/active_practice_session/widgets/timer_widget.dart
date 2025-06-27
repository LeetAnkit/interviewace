import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TimerWidget extends StatelessWidget {
  final int remainingTime;
  final int totalTime;
  final bool isThinkingTime;
  final int thinkingTimeRemaining;

  const TimerWidget({
    super.key,
    required this.remainingTime,
    required this.totalTime,
    required this.isThinkingTime,
    required this.thinkingTimeRemaining,
  });

  Color _getTimerColor() {
    if (isThinkingTime) {
      return AppTheme.lightTheme.colorScheme.tertiary;
    }

    final percentage = remainingTime / totalTime;
    if (percentage > 0.5) {
      return AppTheme.lightTheme.colorScheme.secondary;
    } else if (percentage > 0.25) {
      return AppTheme.lightTheme.colorScheme.tertiary;
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final displayTime = isThinkingTime ? thinkingTimeRemaining : remainingTime;
    final timerColor = _getTimerColor();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: timerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: timerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: isThinkingTime ? 'lightbulb' : 'timer',
            color: timerColor,
            size: 24,
          ),
          SizedBox(width: 2.w),
          Text(
            isThinkingTime ? 'Thinking Time: ' : 'Time Remaining: ',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: timerColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            _formatTime(displayTime),
            style: AppTheme.dataTextStyleMedium(
              isLight: true,
              fontSize: 18,
            ).copyWith(
              color: timerColor,
            ),
          ),
          if (isThinkingTime) ...[
            SizedBox(width: 2.w),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
