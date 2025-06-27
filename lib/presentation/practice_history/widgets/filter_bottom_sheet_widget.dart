import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late String _selectedCategory;
  late String _selectedScoreRange;
  late String _selectedTimeRange;
  late String _selectedInputMethod;

  final List<String> _categories = [
    'All',
    'General',
    'Behavioral',
    'Technical',
    'Company-specific',
    'Career Goals'
  ];

  final List<String> _scoreRanges = [
    'All Scores',
    '9.0 - 10.0',
    '8.0 - 8.9',
    '7.0 - 7.9',
    '6.0 - 6.9',
    'Below 6.0'
  ];

  final List<String> _timeRanges = [
    'All Time',
    'Last 7 days',
    'Last 30 days',
    'Last 3 months',
    'Last 6 months'
  ];

  final List<String> _inputMethods = ['All Methods', 'Voice Only', 'Text Only'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedFilter;
    _selectedScoreRange = 'All Scores';
    _selectedTimeRange = 'All Time';
    _selectedInputMethod = 'All Methods';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    'Category',
                    _categories,
                    _selectedCategory,
                    (value) => setState(() => _selectedCategory = value),
                  ),
                  SizedBox(height: 4.h),
                  _buildFilterSection(
                    'Score Range',
                    _scoreRanges,
                    _selectedScoreRange,
                    (value) => setState(() => _selectedScoreRange = value),
                  ),
                  SizedBox(height: 4.h),
                  _buildFilterSection(
                    'Time Range',
                    _timeRanges,
                    _selectedTimeRange,
                    (value) => setState(() => _selectedTimeRange = value),
                  ),
                  SizedBox(height: 4.h),
                  _buildFilterSection(
                    'Input Method',
                    _inputMethods,
                    _selectedInputMethod,
                    (value) => setState(() => _selectedInputMethod = value),
                  ),
                  SizedBox(height: 4.h),
                  _buildDateRangePicker(),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Filter Sessions',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  option,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Date Range',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                  'From Date', DateTime.now().subtract(Duration(days: 30))),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildDateField('To Date', DateTime.now()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime initialDate) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime.now().subtract(Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          // Handle date selection
        }
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 0.5.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  '${initialDate.day}/${initialDate.month}/${initialDate.year}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _selectedScoreRange = 'All Scores';
                  _selectedTimeRange = 'All Time';
                  _selectedInputMethod = 'All Methods';
                });
              },
              child: Text('Clear All'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onFilterChanged(_selectedCategory);
                Navigator.pop(context);
              },
              child: Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
