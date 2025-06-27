import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SessionControlsWidget extends StatelessWidget {
  final bool hasResponse;
  final VoidCallback onSubmit;
  final VoidCallback onSkip;
  final bool isRecording;

  const SessionControlsWidget({
    super.key,
    required this.hasResponse,
    required this.onSubmit,
    required this.onSkip,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasResponse && !isRecording ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasResponse && !isRecording
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              foregroundColor: hasResponse && !isRecording
                  ? Colors.white
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: hasResponse && !isRecording ? 2 : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'send',
                  color: hasResponse && !isRecording
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Submit Answer',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: hasResponse && !isRecording
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Skip button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: !isRecording ? onSkip : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: !isRecording
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              side: BorderSide(
                color: !isRecording
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'skip_next',
                  color: !isRecording
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Skip Question',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: !isRecording
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Status indicator
        if (isRecording)
          Container(
            margin: EdgeInsets.only(top: 2.h),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Recording in progress...',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
