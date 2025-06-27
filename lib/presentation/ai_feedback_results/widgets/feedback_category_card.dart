import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FeedbackCategoryCard extends StatefulWidget {
  final Map<String, dynamic> category;

  const FeedbackCategoryCard({
    super.key,
    required this.category,
  });

  @override
  State<FeedbackCategoryCard> createState() => _FeedbackCategoryCardState();
}

class _FeedbackCategoryCardState extends State<FeedbackCategoryCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return AppTheme.lightTheme.colorScheme.secondary;
    if (score >= 6.0) return const Color(0xFFF39C12);
    return AppTheme.lightTheme.colorScheme.error;
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Feedback copied to clipboard"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = widget.category["score"] as double;
    final scoreColor = _getScoreColor(score);

    return GestureDetector(
      onLongPress: () {
        final fullText = "${widget.category["name"]}\n"
            "Score: ${score.toStringAsFixed(1)}/10\n"
            "Summary: ${widget.category["summary"]}\n"
            "Details:\n${(widget.category["details"] as List).join('\n')}";
        _copyToClipboard(fullText);
      },
      child: Container(
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
          children: [
            // Header
            InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    // Score Circle
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scoreColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          score.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: scoreColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),

                    // Category Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category["name"],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            widget.category["summary"],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                    ),
                            maxLines: _isExpanded ? null : 2,
                            overflow:
                                _isExpanded ? null : TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Expand Icon
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: CustomIconWidget(
                        iconName: 'keyboard_arrow_down',
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable Content
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color:
                          isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                      height: 1,
                    ),
                    SizedBox(height: 3.h),

                    // Detailed Analysis
                    Text(
                      "Detailed Analysis",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 1.h),

                    ...(widget.category["details"] as List).map((detail) {
                      final detailStr = detail as String;
                      Color iconColor;
                      String iconName;

                      if (detailStr.startsWith('✓')) {
                        iconColor = AppTheme.lightTheme.colorScheme.secondary;
                        iconName = 'check_circle';
                      } else if (detailStr.startsWith('⚠')) {
                        iconColor = const Color(0xFFF39C12);
                        iconName = 'warning';
                      } else {
                        iconColor = AppTheme.lightTheme.colorScheme.error;
                        iconName = 'cancel';
                      }

                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomIconWidget(
                              iconName: iconName,
                              color: iconColor,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                detailStr.substring(2), // Remove emoji prefix
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      height: 1.4,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 2.h),

                    // Examples
                    if (widget.category["examples"] != null) ...[
                      Text(
                        "Examples",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 1.h),
                      ...(widget.category["examples"] as List).map((example) {
                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 1.h),
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppTheme.backgroundDark
                                    : AppTheme.backgroundLight)
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.borderDark
                                  : AppTheme.borderLight,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            example as String,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                      height: 1.3,
                                    ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
