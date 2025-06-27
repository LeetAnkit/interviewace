import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DifficultySelectorWidget extends StatelessWidget {
  final String selectedDifficulty;
  final Function(String) onDifficultyChanged;

  const DifficultySelectorWidget({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
  });

  final List<Map<String, dynamic>> difficultyLevels = const [
    {
      "level": "Beginner",
      "description": "Basic questions suitable for entry-level positions",
      "icon": "star_border"
    },
    {
      "level": "Intermediate",
      "description": "Moderate complexity for experienced professionals",
      "icon": "star_half"
    },
    {
      "level": "Advanced",
      "description": "Complex scenarios for senior-level roles",
      "icon": "star"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty Level',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Choose the complexity level that matches your experience',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Column(
            children: difficultyLevels.map((difficulty) {
              final isSelected = selectedDifficulty == difficulty["level"];
              final isLast = difficulty == difficultyLevels.last;

              return Column(
                children: [
                  GestureDetector(
                    onTap: () =>
                        onDifficultyChanged(difficulty["level"] as String),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: difficulty["level"] as String,
                            groupValue: selectedDifficulty,
                            onChanged: (value) {
                              if (value != null) {
                                onDifficultyChanged(value);
                              }
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: difficulty["icon"] as String,
                            size: 20,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  difficulty["level"] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  difficulty["description"] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
