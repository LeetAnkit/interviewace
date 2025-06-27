import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/practice_session_card_widget.dart';
import './widgets/progress_chart_widget.dart';

class PracticeHistory extends StatefulWidget {
  const PracticeHistory({super.key});

  @override
  State<PracticeHistory> createState() => _PracticeHistoryState();
}

class _PracticeHistoryState extends State<PracticeHistory>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  bool _isLoading = false;
  bool _isSearching = false;
  bool _isMultiSelectMode = false;
  final List<int> _selectedSessions = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';

  // Mock data for practice sessions
  final List<Map<String, dynamic>> _practiceSessionsData = [
    {
      "id": 1,
      "date": DateTime.now().subtract(Duration(days: 1)),
      "questionPreview":
          "Tell me about yourself and your professional background",
      "overallScore": 8.5,
      "duration": "4:32",
      "inputMethod": "voice",
      "category": "General",
      "feedback":
          "Great confidence and clear articulation. Consider adding more specific examples.",
      "fillerWords": 3,
      "grammarScore": 9.2,
      "clarityScore": 8.8,
      "relevanceScore": 8.0
    },
    {
      "id": 2,
      "date": DateTime.now().subtract(Duration(days: 3)),
      "questionPreview":
          "What are your greatest strengths and how do they apply to this role?",
      "overallScore": 7.8,
      "duration": "3:45",
      "inputMethod": "text",
      "category": "Behavioral",
      "feedback":
          "Good structure but could use more concrete examples to support your points.",
      "fillerWords": 1,
      "grammarScore": 8.5,
      "clarityScore": 7.9,
      "relevanceScore": 7.2
    },
    {
      "id": 3,
      "date": DateTime.now().subtract(Duration(days: 5)),
      "questionPreview":
          "Describe a challenging project you worked on and how you overcame obstacles",
      "overallScore": 9.1,
      "duration": "5:18",
      "inputMethod": "voice",
      "category": "Technical",
      "feedback":
          "Excellent storytelling with clear problem-solution structure. Very engaging response.",
      "fillerWords": 2,
      "grammarScore": 9.0,
      "clarityScore": 9.3,
      "relevanceScore": 9.0
    },
    {
      "id": 4,
      "date": DateTime.now().subtract(Duration(days: 7)),
      "questionPreview": "Why do you want to work for our company?",
      "overallScore": 6.9,
      "duration": "2:56",
      "inputMethod": "text",
      "category": "Company-specific",
      "feedback":
          "Shows research but needs more personal connection to company values.",
      "fillerWords": 0,
      "grammarScore": 8.8,
      "clarityScore": 7.2,
      "relevanceScore": 6.5
    },
    {
      "id": 5,
      "date": DateTime.now().subtract(Duration(days: 10)),
      "questionPreview": "Where do you see yourself in 5 years?",
      "overallScore": 7.5,
      "duration": "3:22",
      "inputMethod": "voice",
      "category": "Career Goals",
      "feedback":
          "Clear vision but could better align with potential career path at the company.",
      "fillerWords": 4,
      "grammarScore": 8.0,
      "clarityScore": 7.8,
      "relevanceScore": 7.2
    }
  ];

  List<Map<String, dynamic>> _filteredSessions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredSessions = List.from(_practiceSessionsData);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreSessions();
    }
  }

  void _loadMoreSessions() {
    // Simulate loading more sessions
    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterSessions();
    });
  }

  void _filterSessions() {
    setState(() {
      _filteredSessions = _practiceSessionsData.where((session) {
        final matchesSearch = _searchQuery.isEmpty ||
            (session["questionPreview"] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (session["category"] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        final matchesFilter =
            _selectedFilter == 'All' || session["category"] == _selectedFilter;

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      _selectedSessions.clear();
    });
  }

  void _toggleSessionSelection(int sessionId) {
    setState(() {
      if (_selectedSessions.contains(sessionId)) {
        _selectedSessions.remove(sessionId);
      } else {
        _selectedSessions.add(sessionId);
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) {
          setState(() {
            _selectedFilter = filter;
            _filterSessions();
          });
        },
      ),
    );
  }

  void _navigateToSessionDetail(Map<String, dynamic> session) {
    Navigator.pushNamed(context, '/ai-feedback-results', arguments: session);
  }

  void _deleteSession(int sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Session',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete this practice session? This action cannot be undone.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _practiceSessionsData
                    .removeWhere((session) => session["id"] == sessionId);
                _filterSessions();
              });
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _shareSession(Map<String, dynamic> session) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Session shared successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportSessions() {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sessions exported as PDF'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHistoryTab(),
                  _buildProgressTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isMultiSelectMode
          ? _buildMultiSelectFAB()
          : FloatingActionButton(
              onPressed: _showFilterBottomSheet,
              child: CustomIconWidget(
                iconName: 'filter_list',
                color: Colors.white,
                size: 24,
              ),
            ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (_isMultiSelectMode) ...[
                IconButton(
                  onPressed: _toggleMultiSelect,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '${_selectedSessions.length} selected',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
              ] else ...[
                Text(
                  'Practice History',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              Spacer(),
              if (!_isMultiSelectMode) ...[
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: _isSearching ? 'close' : 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                IconButton(
                  onPressed: _toggleMultiSelect,
                  icon: CustomIconWidget(
                    iconName: 'more_vert',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ],
          ),
          if (_isSearching) ...[
            SizedBox(height: 2.h),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search sessions...',
                prefixIcon: CustomIconWidget(
                  iconName: 'search',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: 'History'),
          Tab(text: 'Progress'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_filteredSessions.isEmpty && _searchQuery.isEmpty) {
      return EmptyStateWidget(
        onStartPractice: () {
          Navigator.pushNamed(context, '/practice-session-setup');
        },
      );
    }

    if (_filteredSessions.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'No sessions found',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search terms',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _onRefresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(4.w),
        itemCount: _filteredSessions.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredSessions.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final session = _filteredSessions[index];
          final isSelected = _selectedSessions.contains(session["id"]);

          return PracticeSessionCardWidget(
            session: session,
            isMultiSelectMode: _isMultiSelectMode,
            isSelected: isSelected,
            onTap: () {
              if (_isMultiSelectMode) {
                _toggleSessionSelection(session["id"] as int);
              } else {
                _navigateToSessionDetail(session);
              }
            },
            onLongPress: () {
              if (!_isMultiSelectMode) {
                _toggleMultiSelect();
                _toggleSessionSelection(session["id"] as int);
              }
            },
            onDelete: () => _deleteSession(session["id"] as int),
            onShare: () => _shareSession(session),
          );
        },
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 3.h),
          ProgressChartWidget(sessions: _practiceSessionsData),
          SizedBox(height: 4.h),
          _buildProgressStats(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Analytics',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 3.h),
          _buildAnalyticsCards(),
        ],
      ),
    );
  }

  Widget _buildProgressStats() {
    final totalSessions = _practiceSessionsData.length;
    final averageScore = _practiceSessionsData.isEmpty
        ? 0.0
        : _practiceSessionsData
                .map((s) => s["overallScore"] as double)
                .reduce((a, b) => a + b) /
            totalSessions;
    final totalDuration = _practiceSessionsData
        .map((s) => s["duration"] as String)
        .map((d) => _parseDuration(d))
        .reduce((a, b) => a + b);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Sessions',
                totalSessions.toString(),
                CustomIconWidget(
                  iconName: 'quiz',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildStatCard(
                'Average Score',
                averageScore.toStringAsFixed(1),
                CustomIconWidget(
                  iconName: 'star',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Practice Time',
                _formatDuration(totalDuration),
                CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildStatCard(
                'Improvement',
                '+12%',
                CustomIconWidget(
                  iconName: 'trending_up',
                  color: Colors.green,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Widget icon) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              icon,
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards() {
    return Column(
      children: [
        _buildAnalyticsCard(
          'Speaking Confidence',
          '85%',
          'Improved by 15% this month',
          Colors.blue,
          0.85,
        ),
        SizedBox(height: 3.h),
        _buildAnalyticsCard(
          'Grammar Accuracy',
          '92%',
          'Excellent performance',
          Colors.green,
          0.92,
        ),
        SizedBox(height: 3.h),
        _buildAnalyticsCard(
          'Response Relevance',
          '78%',
          'Room for improvement',
          Colors.orange,
          0.78,
        ),
        SizedBox(height: 3.h),
        _buildAnalyticsCard(
          'Filler Words',
          '2.5 avg',
          'Reduced by 30%',
          Colors.purple,
          0.7,
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    String subtitle,
    Color color,
    double progress,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectFAB() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "delete",
          onPressed: _selectedSessions.isEmpty
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete Sessions'),
                      content: Text(
                          'Delete ${_selectedSessions.length} selected sessions?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _practiceSessionsData.removeWhere((session) =>
                                  _selectedSessions.contains(session["id"]));
                              _filterSessions();
                              _selectedSessions.clear();
                              _isMultiSelectMode = false;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Delete',
                            style: TextStyle(
                                color: AppTheme.lightTheme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
          backgroundColor: _selectedSessions.isEmpty
              ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
              : AppTheme.lightTheme.colorScheme.error,
          child: CustomIconWidget(
            iconName: 'delete',
            color: Colors.white,
            size: 24,
          ),
        ),
        SizedBox(width: 4.w),
        FloatingActionButton(
          heroTag: "export",
          onPressed: _selectedSessions.isEmpty ? null : _exportSessions,
          backgroundColor: _selectedSessions.isEmpty
              ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
              : AppTheme.lightTheme.colorScheme.primary,
          child: CustomIconWidget(
            iconName: 'file_download',
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  int _parseDuration(String duration) {
    final parts = duration.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}