import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AudioPlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final double position;
  final double duration;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSeek;
  final VoidCallback onToggleTranscript;
  final bool showTranscript;
  final String transcript;

  const AudioPlaybackControls({
    super.key,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onSeek,
    required this.onToggleTranscript,
    required this.showTranscript,
    required this.transcript,
  });

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  List<TextSpan> _buildHighlightedTranscript(String text, bool isDark) {
    final List<TextSpan> spans = [];
    final fillerWords = ['um', 'uh', 'like', 'you know', 'well'];
    final words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      final word = words[i].toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
      final isFillerWord = fillerWords.any((filler) => word.contains(filler));

      spans.add(TextSpan(
        text: '${words[i]}${i < words.length - 1 ? ' ' : ''}',
        style: TextStyle(
          color: isFillerWord
              ? AppTheme.lightTheme.colorScheme.error
              : (isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight),
          backgroundColor: isFillerWord
              ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1)
              : null,
          fontWeight: isFillerWord ? FontWeight.w600 : FontWeight.normal,
        ),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'headphones',
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                "Audio Playback",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onToggleTranscript,
                icon: CustomIconWidget(
                  iconName: showTranscript ? 'visibility_off' : 'visibility',
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  size: 16,
                ),
                label: Text(
                  showTranscript ? "Hide" : "Show",
                  style: TextStyle(
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Playback Controls
          Row(
            children: [
              // Play/Pause Button
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onPlayPause,
                  icon: CustomIconWidget(
                    iconName: isPlaying ? 'pause' : 'play_arrow',
                    color: isDark ? Colors.black : Colors.white,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: 3.w),

              // Progress Slider
              Expanded(
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                      ),
                      child: Slider(
                        value: position,
                        max: duration,
                        onChanged: onSeek,
                        activeColor: isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight,
                        inactiveColor: (isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _formatDuration(duration),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Transcript Section
          if (showTranscript) ...[
            SizedBox(height: 3.h),
            Divider(
              color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            ),
            SizedBox(height: 2.h),

            Row(
              children: [
                CustomIconWidget(
                  iconName: 'transcript',
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  "Transcript",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: (isDark
                        ? AppTheme.backgroundDark
                        : AppTheme.backgroundLight)
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  width: 1,
                ),
              ),
              child: RichText(
                text: TextSpan(
                  children: _buildHighlightedTranscript(transcript, isDark),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
              ),
            ),
            SizedBox(height: 1.h),

            // Legend
            Wrap(
              spacing: 4.w,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.error
                            .withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      "Filler words",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
