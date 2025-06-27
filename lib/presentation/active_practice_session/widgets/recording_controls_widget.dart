import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecordingControlsWidget extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final VoidCallback onPlayback;
  final bool isPlayingBack;

  const RecordingControlsWidget({
    super.key,
    required this.isRecording,
    required this.isPaused,
    required this.onPause,
    required this.onStop,
    required this.onPlayback,
    required this.isPlayingBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pause/Resume button
          if (isRecording)
            _buildControlButton(
              icon: isPaused ? 'play_arrow' : 'pause',
              label: isPaused ? 'Resume' : 'Pause',
              onTap: onPause,
              color: AppTheme.lightTheme.colorScheme.tertiary,
            ),

          // Stop button
          if (isRecording)
            _buildControlButton(
              icon: 'stop',
              label: 'Stop',
              onTap: onStop,
              color: AppTheme.lightTheme.colorScheme.error,
            ),

          // Playback button
          if (!isRecording)
            _buildControlButton(
              icon: isPlayingBack ? 'pause' : 'play_arrow',
              label: isPlayingBack ? 'Pause' : 'Play',
              onTap: onPlayback,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: color,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
