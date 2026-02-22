import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'constants/routes.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/checklist/checklist_screen.dart';
import 'screens/checklist/phase2_screen.dart';
import 'screens/checklist/phase3_screen.dart';
import 'screens/report/report_screen.dart';
import 'screens/result/result_info_screen.dart';
import 'screens/result/result_emotion_screen.dart';
import 'screens/couple_mode/couple_mode_screen.dart';

// Use CupertinoPage for all routes — gives native iOS slide transition
// and preserves edge-swipe-back gesture automatically.
Page<void> _ios(Widget child) =>
    CupertinoPage(child: child);

final appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      pageBuilder: (_, _) => _ios(const SplashScreen()),
    ),
    GoRoute(
      path: Routes.home,
      pageBuilder: (_, _) => _ios(const HomeScreen()),
    ),
    GoRoute(
      path: Routes.checklist,
      pageBuilder: (_, _) => _ios(const ChecklistScreen()),
      routes: [
        GoRoute(
          path: 'phase2',
          pageBuilder: (_, _) => _ios(const Phase2Screen()),
        ),
        GoRoute(
          path: 'phase3',
          pageBuilder: (_, _) => _ios(const Phase3Screen()),
        ),
      ],
    ),
    GoRoute(
      path: Routes.report,
      pageBuilder: (_, _) => _ios(const ReportScreen()),
    ),
    GoRoute(
      path: Routes.resultInfo,
      pageBuilder: (_, _) => _ios(const ResultInfoScreen()),
    ),
    GoRoute(
      path: Routes.resultEmotion,
      pageBuilder: (_, _) => _ios(const ResultEmotionScreen()),
    ),
    GoRoute(
      path: Routes.coupleMode,
      pageBuilder: (_, _) => _ios(const CoupleModeScreen()),
    ),
  ],
);
