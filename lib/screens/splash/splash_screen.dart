import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    _line1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _line2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _line1Opacity = CurvedAnimation(
      parent: _line1Controller,
      curve: Curves.easeIn,
    );
    _line2Opacity = CurvedAnimation(
      parent: _line2Controller,
      curve: Curves.easeIn,
    );
    _buttonOpacity = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeIn,
    );

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),

              // Line 1
              FadeTransition(
                opacity: _line1Opacity,
                child: Text(
                  '70% of people had already seen the signs\nbefore they found out.',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),

              const SizedBox(height: 28),

              // Line 2
              FadeTransition(
                opacity: _line2Opacity,
                child: Text(
                  'They just didn\'t realize it at the time.',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w300,
                      ),
                ),
              ),

              const Spacer(flex: 2),

              // CTA button
              FadeTransition(
                opacity: _buttonOpacity,
                child: SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => context.go(Routes.home),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Begin Detection',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
