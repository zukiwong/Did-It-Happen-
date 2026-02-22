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

final appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (_, _) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.home,
      builder: (_, _) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.checklist,
      builder: (_, _) => const ChecklistScreen(),
      routes: [
        GoRoute(
          path: 'phase2',
          builder: (_, _) => const Phase2Screen(),
        ),
        GoRoute(
          path: 'phase3',
          builder: (_, _) => const Phase3Screen(),
        ),
      ],
    ),
    GoRoute(
      path: Routes.report,
      builder: (_, _) => const ReportScreen(),
    ),
    GoRoute(
      path: Routes.resultInfo,
      builder: (_, _) => const ResultInfoScreen(),
    ),
    GoRoute(
      path: Routes.resultEmotion,
      builder: (_, _) => const ResultEmotionScreen(),
    ),
    GoRoute(
      path: Routes.coupleMode,
      builder: (_, _) => const CoupleModeScreen(),
    ),
  ],
);
