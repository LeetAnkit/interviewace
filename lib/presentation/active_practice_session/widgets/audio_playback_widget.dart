import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AudioPlaybackWidget extends StatelessWidget {
  final double progress;
  final bool isPlaying;
  final Function(double) onSeek;
  final VoidCallback onTogglePlayback;

  const AudioPlaybackWidget({
    super.key,
    required this.progress,
    required this.isPlaying,
    required this.onSeek,
    required this.onTogglePlayback,
  });

  String _formatDuration(double progress) {
    final totalSeconds = (progress * 120).round(); // Assuming 2 minutes max
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Playback header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'audiotrack',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Your Recording',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                _formatDuration(progress),
                style: AppTheme.dataTextStyle(
                  isLight: true,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Progress bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: progress,
              onChanged: onSeek,
              activeColor: AppTheme.lightTheme.colorScheme.primary,
              inactiveColor: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),

          SizedBox(height: 1.h),

          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind button
              IconButton(
                onPressed: () => onSeek((progress - 0.1).clamp(0.0, 1.0)),
                icon: CustomIconWidget(
                  iconName: 'replay_10',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),

              SizedBox(width: 4.w),

              // Play/Pause button
              GestureDetector(
                onTap: onTogglePlayback,
                child: Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CustomIconWidget(
                    iconName: isPlaying ? 'pause' : 'play_arrow',
                    color: Colors.white,
                    size: 8.w,
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Forward button
              IconButton(
                onPressed: () => onSeek((progress + 0.1).clamp(0.0, 1.0)),
                icon: CustomIconWidget(
                  iconName: 'forward_10',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
