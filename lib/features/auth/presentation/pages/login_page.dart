import 'package:fin_track_pro/config/router/routes.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/core/widgets/app_text_field.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/login_form_cubit/login_form_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => LoginFormCubit(authBloc: ctx.read<AuthBloc>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  void _listener(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.error) {
      AppSnackbar().error(
        context,
        mapFirebaseAuthError(state.errorMessage, context.l10n),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: BlocListener<AuthBloc, AuthState>(
        listener: _listener,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(48),
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 64,
                  color: context.colorScheme.primary,
                ),
                const Gap(24),
                Text(
                  context.l10n.welcomeBack,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                Text(
                  'FinTrack Pro',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(48),
                _EmailField(),
                const Gap(16),
                _PasswordField(),
                const Gap(24),
                _SubmitButton(),
                const Gap(16),
                _GoogleSignInButton(),
                const Gap(32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.dontHaveAccount,
                      style: context.textTheme.bodyMedium,
                    ),
                    const Gap(8),
                    TextButton(
                      key: const Key('go_to_register_button'),
                      onPressed: () => context.push(RouteConstants.register),
                      child: Text(context.l10n.signUp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginFormCubit, LoginFormState>(
      buildWhen: (prev, curr) => prev.email != curr.email,
      builder: (context, state) {
        return AppTextField(
          key: const Key('login_email_field'),
          label: context.l10n.email,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          // Live validation: show error as soon as the field is dirty and invalid.
          errorText: state.email.displayError != null
              ? context.l10n.invalidEmail
              : null,
          onChanged: context.read<LoginFormCubit>().emailChanged,
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginFormCubit, LoginFormState>(
      buildWhen: (prev, curr) => prev.password != curr.password,
      builder: (context, state) {
        return AppTextField(
          key: const Key('login_password_field'),
          label: context.l10n.password,
          prefixIcon: Icons.lock_outlined,
          obscureText: true,
          showObscureToggle: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          // Live validation: show error as soon as the field is dirty and invalid.
          errorText: state.password.displayError != null
              ? context.l10n.passwordTooShort
              : null,
          onChanged: context.read<LoginFormCubit>().passwordChanged,
          onSubmitted: (_) => context.read<LoginFormCubit>().onSubmit(),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginFormCubit, LoginFormState>(
      buildWhen: (prev, curr) =>
          prev.isPosting != curr.isPosting || prev.isValid != curr.isValid,
      builder: (context, state) {
        return FilledButton(
          key: const Key('login_submit_button'),
          onPressed: state.isPosting
              ? null
              : () => context.read<LoginFormCubit>().onSubmit(),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: state.isPosting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(context.l10n.signIn),
        );
      },
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('google_sign_in_button'),
      onPressed: () =>
          context.read<AuthBloc>().add(AuthSignInWithGoogleRequested()),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      icon: const Icon(Icons.login, size: 20),
      label: Text(context.l10n.signInWithGoogle),
    );
  }
}
