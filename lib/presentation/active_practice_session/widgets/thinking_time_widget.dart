import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ThinkingTimeWidget extends StatelessWidget {
  final VoidCallback onActivate;
  final bool isEnabled;

  const ThinkingTimeWidget({
    super.key,
    required this.onActivate,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onActivate : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppTheme.lightTheme.colorScheme.tertiaryContainer
              : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          foregroundColor: isEnabled
              ? AppTheme.lightTheme.colorScheme.onTertiaryContainer
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isEnabled ? 2 : 0,
        ),
        icon: CustomIconWidget(
          iconName: 'lightbulb',
          color: isEnabled
              ? AppTheme.lightTheme.colorScheme.tertiary
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Need Thinking Time?',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: isEnabled
                    ? AppTheme.lightTheme.colorScheme.onTertiaryContainer
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Get 30 seconds to collect your thoughts',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isEnabled
                    ? AppTheme.lightTheme.colorScheme.onTertiaryContainer
                        .withValues(alpha: 0.8)
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
