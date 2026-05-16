import 'package:flutter/material.dart';

import '../presentation/notifications_screen/notifications_screen.dart';
import '../presentation/reports_export_screen/reports_export_screen.dart';
import '../presentation/risk_assessment_form_screen/risk_assessment_form_screen.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart';
import '../presentation/submission_history_screen/submission_history_screen.dart';
import '../presentation/supervisor_dashboard_screen/supervisor_dashboard_screen.dart';
import '../presentation/admin_user_management_screen/admin_user_management_screen.dart';
import '../presentation/analytics_dashboard_screen/analytics_dashboard_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String signUpLoginScreen = '/sign-up-login-screen';
  static const String riskAssessmentFormScreen = '/risk-assessment-form-screen';
  static const String submissionHistoryScreen = '/submission-history-screen';
  static const String notificationsScreen = '/notifications-screen';
  static const String supervisorDashboardScreen =
      '/supervisor-dashboard-screen';
  static const String reportsExportScreen = '/reports-export-screen';
  static const String adminUserManagementScreen =
      '/admin-user-management-screen';
  static const String analyticsDashboardScreen = '/analytics-dashboard-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SignUpLoginScreen(),
    signUpLoginScreen: (context) => const SignUpLoginScreen(),
    riskAssessmentFormScreen: (context) => const RiskAssessmentFormScreen(),
    submissionHistoryScreen: (context) => const SubmissionHistoryScreen(),
    notificationsScreen: (context) => const NotificationsScreen(),
    supervisorDashboardScreen: (context) => const SupervisorDashboardScreen(),
    reportsExportScreen: (context) => const ReportsExportScreen(),
    adminUserManagementScreen: (context) => const AdminUserManagementScreen(),
    analyticsDashboardScreen: (context) => const AnalyticsDashboardScreen(),
  };
}
