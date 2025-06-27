import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/continue_session_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/quick_stats_widget.dart';
import './widgets/recent_activity_widget.dart';
import './widgets/start_practice_card_widget.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoading = false;

  // Mock user data
  final Map<String, dynamic> userData = {
    "name": "Alex Johnson",
    "currentStreak": 7,
    "sessionsThisWeek": 12,
    "averageScore": 8.4,
    "improvementPercentage": 15.2,
    "hasIncompleteSession": true,
    "lastSessionQuestion":
        "Tell me about a time when you had to work under pressure.",
    "lastSessionCategory": "Behavioral"
  };

  // Mock recent activities
  final List<Map<String, dynamic>> recentActivities = [
    {
      "id": 1,
      "category": "Technical",
      "question": "Explain the difference between REST and GraphQL APIs",
      "score": 9.2,
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "duration": "8 min",
      "feedback": "Excellent technical explanation with clear examples"
    },
    {
      "id": 2,
      "category": "Behavioral",
      "question": "Describe a challenging project you worked on",
      "score": 7.8,
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
      "duration": "12 min",
      "feedback": "Good structure, could improve on specific metrics"
    },
    {
      "id": 3,
      "category": "Leadership",
      "question": "How do you handle team conflicts?",
      "score": 8.5,
      "timestamp": DateTime.now().subtract(Duration(days: 2)),
      "duration": "10 min",
      "feedback": "Strong leadership approach with practical examples"
    },
    {
      "id": 4,
      "category": "Problem Solving",
      "question": "Walk me through your problem-solving process",
      "score": 8.9,
      "timestamp": DateTime.now().subtract(Duration(days: 3)),
      "duration": "15 min",
      "feedback": "Systematic approach with clear methodology"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 12.h,
                floating: true,
                pinned: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: GreetingHeaderWidget(
                      userName: userData["name"] as String,
                      currentStreak: userData["currentStreak"] as int,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 2.h),
                    StartPracticeCardWidget(
                      onTap: () => _navigateToScreen('/practice-session-setup'),
                    ),
                    SizedBox(height: 3.h),
                    QuickStatsWidget(
                      sessionsThisWeek: userData["sessionsThisWeek"] as int,
                      averageScore: userData["averageScore"] as double,
                      improvementPercentage:
                          userData["improvementPercentage"] as double,
                    ),
                    SizedBox(height: 3.h),
                    if (userData["hasIncompleteSession"] == true) ...[
                      ContinueSessionWidget(
                        questionPreview:
                            userData["lastSessionQuestion"] as String,
                        category: userData["lastSessionCategory"] as String,
                        onResume: () =>
                            _navigateToScreen('/active-practice-session'),
                      ),
                      SizedBox(height: 3.h),
                    ],
                    RecentActivityWidget(
                      activities: recentActivities,
                      onActivityTap: _handleActivityTap,
                      onActivityLongPress: _handleActivityLongPress,
                    ),
                    SizedBox(height: 10.h),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: Theme.of(context).platform == TargetPlatform.android
          ? FloatingActionButton(
              onPressed: () => _navigateToScreen('/practice-session-setup'),
              child: CustomIconWidget(
                iconName: 'mic',
                color: Colors.white,
                size: 6.w,
              ),
            )
          : null,
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      selectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      elevation: 4.0,
      onTap: _onBottomNavTap,
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'home',
            color: _currentIndex == 0
                ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor!
                : Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor!,
            size: 5.w,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'play_circle_filled',
            color: _currentIndex == 1
                ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor!
                : Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor!,
            size: 5.w,
          ),
          label: 'Practice',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'history',
            color: _currentIndex == 2
                ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor!
                : Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor!,
            size: 5.w,
          ),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'person',
            color: _currentIndex == 3
                ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor!
                : Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor!,
            size: 5.w,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        _navigateToScreen('/practice-session-setup');
        break;
      case 2:
        _navigateToScreen('/practice-history');
        break;
      case 3:
        _navigateToScreen('/user-profile-settings');
        break;
    }
  }

  void _navigateToScreen(String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data refreshed successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleActivityTap(Map<String, dynamic> activity) {
    Navigator.pushNamed(
      context,
      '/ai-feedback-results',
      arguments: activity,
    );
  }

  void _handleActivityLongPress(Map<String, dynamic> activity) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: Theme.of(context).colorScheme.primary,
                size: 5.w,
              ),
              title: Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _handleActivityTap(activity);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).colorScheme.primary,
                size: 5.w,
              ),
              title: Text('Share Results'),
              onTap: () {
                Navigator.pop(context);
                _shareResults(activity);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: Theme.of(context).colorScheme.error,
                size: 5.w,
              ),
              title: Text('Delete Session'),
              onTap: () {
                Navigator.pop(context);
                _deleteSession(activity);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _shareResults(Map<String, dynamic> activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing results for ${activity["category"]} session'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteSession(Map<String, dynamic> activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Session'),
        content: Text(
            'Are you sure you want to delete this practice session? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                recentActivities
                    .removeWhere((item) => item["id"] == activity["id"]);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Session deleted successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
