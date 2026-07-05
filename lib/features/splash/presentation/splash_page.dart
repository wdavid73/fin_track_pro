import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fin_track_pro/config/router/routes.dart';
import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/features/settings/domain/usecases/check_onboarding_status.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Simulate splash screen delay
    await Future.delayed(const Duration(seconds: 2));

    final hasSeenOnboarding = await getIt<CheckOnboardingStatus>().call();

    if (mounted) {
      if (hasSeenOnboarding) {
        context.go(RouteConstants.home);
      } else {
        context.go(RouteConstants.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              'FinTrack Pro',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(color: theme.colorScheme.onPrimary),
          ],
        ),
      ),
    );
  }
}
