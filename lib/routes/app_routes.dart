import 'package:flutter/material.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/user_profile_settings/user_profile_settings.dart';
import '../presentation/practice_session_setup/practice_session_setup.dart';
import '../presentation/active_practice_session/active_practice_session.dart';
import '../presentation/practice_history/practice_history.dart';
import '../presentation/ai_feedback_results/ai_feedback_results.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String homeDashboard = '/home-dashboard';
  static const String userProfileSettings = '/user-profile-settings';
  static const String practiceSessionSetup = '/practice-session-setup';
  static const String activePracticeSession = '/active-practice-session';
  static const String practiceHistory = '/practice-history';
  static const String aiFeedbackResults = '/ai-feedback-results';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const HomeDashboard(),
    homeDashboard: (context) => const HomeDashboard(),
    userProfileSettings: (context) => const UserProfileSettings(),
    practiceSessionSetup: (context) => const PracticeSessionSetup(),
    activePracticeSession: (context) => const ActivePracticeSession(),
    practiceHistory: (context) => const PracticeHistory(),
    aiFeedbackResults: (context) => const AiFeedbackResults(),
    // TODO: Add your other routes here
  };
}
