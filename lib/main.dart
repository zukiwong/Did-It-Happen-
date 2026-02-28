import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/investigation_provider.dart';
import 'screens/splash/splash_screen.dart'; // also exports UserChoice
import 'screens/checklist/trace_checklist_screen.dart';
import 'screens/checklist/self_risk_check_screen.dart';
import 'screens/report/trace_report_screen.dart';
import 'screens/report/self_reflection_screen.dart';
import 'screens/sanctuary/mind_sanctuary_screen.dart';
import 'screens/archive/archive_access_screen.dart';
import 'screens/archive/trace_archive_screen.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: '出了吗？',
      debugShowCheckedModeBanner: false,
      home: _AppNavigator(),
    );
  }
}

enum _AppScreen {
  splash,
  traceChecklist,
  traceReport,
  selfRiskCheck,
  selfReflection,
  sanctuary,
  archiveAccess,
  archive,
}

class _AppNavigator extends ConsumerStatefulWidget {
  const _AppNavigator();

  @override
  ConsumerState<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends ConsumerState<_AppNavigator> {
  final List<_AppScreen> _stack = [_AppScreen.splash];
  _AppScreen get _current => _stack.last;

  void _push(_AppScreen screen) => setState(() => _stack.add(screen));

  void _pop() {
    if (_stack.length > 1) setState(() => _stack.removeLast());
  }

  void _replaceWithSplash() {
    setState(() {
      _stack.clear();
      _stack.add(_AppScreen.splash);
    });
  }

  void _onChoice(UserChoice choice) {
    switch (choice) {
      case UserChoice.partner:
        ref.read(investigationProvider.notifier).startSession(entryType: 'partner');
        _push(_AppScreen.traceChecklist);
      case UserChoice.self:
        ref.read(investigationProvider.notifier).startSession(entryType: 'self');
        _push(_AppScreen.selfRiskCheck);
      case UserChoice.records:
        _push(_AppScreen.archiveAccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildScreen(_current);
  }

  Widget _buildScreen(_AppScreen screen) {
    switch (screen) {
      // Splash + choice are now one combined screen
      case _AppScreen.splash:
        return SplashScreen(onChoice: _onChoice);

      case _AppScreen.traceChecklist:
        return TraceChecklistScreen(
          onBack: _pop,
          onNext: () => _push(_AppScreen.traceReport),
        );

      case _AppScreen.traceReport:
        return TraceReportScreen(onBack: _pop);

      case _AppScreen.selfRiskCheck:
        return SelfRiskCheckScreen(
          onBack: _pop,
          onComplete: () => _push(_AppScreen.selfReflection),
        );

      case _AppScreen.selfReflection:
        return SelfReflectionScreen(
          onBack: _pop,
          onChat: () => _push(_AppScreen.sanctuary),
          onRecheck: _pop,
          onExit: _replaceWithSplash,
        );

      case _AppScreen.sanctuary:
        return MindSanctuaryScreen(onBack: _pop);

      case _AppScreen.archiveAccess:
        return ArchiveAccessScreen(
          onBack: _pop,
          onSuccess: () => _push(_AppScreen.archive),
        );

      case _AppScreen.archive:
        return TraceArchiveScreen(onBack: _pop);
    }
  }
}
