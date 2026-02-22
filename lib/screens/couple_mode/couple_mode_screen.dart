import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/routes.dart';

/// Couple mode entry screen (paid feature).
/// Per UX doc: not shown at main entry — accessible from report bottom or settings.
/// Flow: create session → invite code → both fill → view compared result.
class CoupleModeScreen extends StatelessWidget {
  const CoupleModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: GestureDetector(
          onTap: () => context.go(Routes.report),
          child: const Icon(Icons.arrow_back_ios, size: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              Text(
                'Couple Detection',
                style: Theme.of(context).textTheme.displayLarge,
              ),

              const SizedBox(height: 12),

              Text(
                'Both partners complete the checklist independently. Results are compared side by side.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 48),

              // How it works
              _Step(number: '01', label: 'Create a shared session'),
              _Step(number: '02', label: 'Send the invite code to your partner'),
              _Step(number: '03', label: 'Each of you fills out the checklist'),
              _Step(number: '04', label: 'View your results side by side'),

              const Spacer(),

              // CTA — placeholder, Supabase integration comes next
              GestureDetector(
                onTap: () {
                  // TODO: create Supabase session and generate invite code
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Start couple detection',
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

class _Step extends StatelessWidget {
  final String number;
  final String label;

  const _Step({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Text(
            number,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.risk,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
