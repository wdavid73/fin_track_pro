import 'package:fin_track_pro/config/router/routes.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/core/widgets/app_text_field.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/register_form_cubit/register_form_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => RegisterFormCubit(authBloc: ctx.read<AuthBloc>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: MultiBlocListener(
        listeners: [
          // Show error messages surfaced by the form cubit.
          BlocListener<RegisterFormCubit, RegisterFormState>(
            listenWhen: (prev, curr) =>
                curr.errorMessage != null &&
                prev.errorMessage != curr.errorMessage,
            listener: (context, state) {
              AppSnackbar().error(
                context,
                state.errorMessage ?? context.l10n.authError,
              );
            },
          ),
          // Navigate to login once registration completes.
          BlocListener<RegisterFormCubit, RegisterFormState>(
            listenWhen: (prev, curr) => curr.registrationComplete && !prev.registrationComplete,
            listener: (context, _) => context.go(RouteConstants.login),
          ),
        ],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.createAccount,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(32),
                _DisplayNameField(),
                const Gap(16),
                _EmailField(),
                const Gap(16),
                _PasswordField(),
                const Gap(16),
                _ConfirmPasswordField(),
                const Gap(24),
                _SubmitButton(),
                const Gap(24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.alreadyHaveAccount,
                      style: context.textTheme.bodyMedium,
                    ),
                    const Gap(8),
                    TextButton(
                      key: const Key('go_to_login_button'),
                      onPressed: () => context.go(RouteConstants.login),
                      child: Text(context.l10n.signIn),
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

class _DisplayNameField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
      buildWhen: (prev, curr) =>
          prev.displayName != curr.displayName ||
          prev.isFormPosted != curr.isFormPosted,
      builder: (context, state) {
        return AppTextField(
          key: const Key('register_name_field'),
          label: context.l10n.displayName,
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          // Optional field — only validate after submit attempt.
          errorText: state.isFormPosted && state.displayName.displayError != null
              ? context.l10n.fieldTooLong
              : null,
          onChanged: context.read<RegisterFormCubit>().displayNameChanged,
        );
      },
    );
  }
}

class _EmailField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
      buildWhen: (prev, curr) => prev.email != curr.email,
      builder: (context, state) {
        return AppTextField(
          key: const Key('register_email_field'),
          label: context.l10n.email,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newUsername],
          // Live validation: show error as soon as the field is dirty and invalid.
          errorText: state.email.displayError != null
              ? context.l10n.invalidEmail
              : null,
          onChanged: context.read<RegisterFormCubit>().emailChanged,
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
      buildWhen: (prev, curr) => prev.password != curr.password,
      builder: (context, state) {
        return AppTextField(
          key: const Key('register_password_field'),
          label: context.l10n.password,
          prefixIcon: Icons.lock_outlined,
          obscureText: true,
          showObscureToggle: true,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          // Live validation: show error as soon as the field is dirty and invalid.
          errorText: state.password.displayError != null
              ? context.l10n.passwordTooShort
              : null,
          onChanged: context.read<RegisterFormCubit>().passwordChanged,
        );
      },
    );
  }
}

class _ConfirmPasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
      buildWhen: (prev, curr) =>
          prev.confirmPassword != curr.confirmPassword ||
          prev.isFormPosted != curr.isFormPosted,
      builder: (context, state) {
        return AppTextField(
          key: const Key('register_confirm_field'),
          label: context.l10n.confirmPassword,
          prefixIcon: Icons.lock_outlined,
          obscureText: true,
          showObscureToggle: true,
          textInputAction: TextInputAction.done,
          // Only show mismatch error after submit attempt or once the field is dirty.
          errorText:
              state.isFormPosted && state.confirmPassword.displayError != null
                  ? context.l10n.passwordsDoNotMatch
                  : null,
          onChanged: context.read<RegisterFormCubit>().confirmPasswordChanged,
          onSubmitted: (_) => context.read<RegisterFormCubit>().onSubmit(),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormCubit, RegisterFormState>(
      buildWhen: (prev, curr) =>
          prev.isPosting != curr.isPosting || prev.isValid != curr.isValid,
      builder: (context, state) {
        return FilledButton(
          key: const Key('register_submit_button'),
          onPressed: state.isPosting
              ? null
              : () => context.read<RegisterFormCubit>().onSubmit(),
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
              : Text(context.l10n.signUp),
        );
      },
    );
  }
}
