import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _line1Controller;
  late final AnimationController _line2Controller;
  late final AnimationController _buttonController;

  late final Animation<double> _line1Opacity;
  late final Animation<double> _line2Opacity;
  late final Animation<double> _buttonOpacity;
  late final Animation<double> _line1Offset;
  late final Animation<double> _line2Offset;
  late final Animation<double> _buttonOffset;

  @override
  void initState() {
    super.initState();
    _line1Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _line2Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _buttonController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _line1Opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _line1Controller, curve: Curves.easeOut));
    _line1Offset = Tween(begin: 6.0, end: 0.0).animate(CurvedAnimation(parent: _line1Controller, curve: Curves.easeOut));
    _line2Opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _line2Controller, curve: Curves.easeOut));
    _line2Offset = Tween(begin: 6.0, end: 0.0).animate(CurvedAnimation(parent: _line2Controller, curve: Curves.easeOut));
    _buttonOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));
    _buttonOffset = Tween(begin: 6.0, end: 0.0).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _line1Controller.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    _line2Controller.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),
              AnimatedBuilder(
                animation: _line1Controller,
                builder: (_, _) => Opacity(
                  opacity: _line1Opacity.value,
                  child: Transform.translate(
                    offset: Offset(0, _line1Offset.value),
                    child: const Text('70%的人，在发现伴侣出轨前\n其实已经看到信号。', style: AppText.display),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedBuilder(
                animation: _line2Controller,
                builder: (_, _) => Opacity(
                  opacity: _line2Opacity.value,
                  child: Transform.translate(
                    offset: Offset(0, _line2Offset.value),
                    child: const Text(
                      '只是当时，没有意识到。',
                      style: TextStyle(
                        fontFamily: '.SF Pro Display',
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: AppColors.textSecondary,
                        height: 1.4,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _buttonController,
                builder: (_, _) => Opacity(
                  opacity: _buttonOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, _buttonOffset.value),
                    child: GestureDetector(
                      onTap: () => context.go(Routes.home),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '开始检测',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.background,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
