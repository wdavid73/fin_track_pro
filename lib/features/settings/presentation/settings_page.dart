import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:fin_track_pro/core/widgets/app_snack_bar.dart';
import 'package:fin_track_pro/core/extensions/context_extensions.dart';

import 'blocs/settings_bloc/settings_bloc.dart';
import 'widgets/theme_option_bottom_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _onTap(BuildContext context) {
    AppSnackbar().show(context, 'Comming soon...');
    // AppSnackbar().success(context, 'Success soon...');
    // AppSnackbar().error(context, 'Error soon...');
    // AppSnackbar().warning(context, 'Warning soon...');
    /* AppSnackbar().custom(
      context: context,
      message: 'Custom soon...',
      background: Colors.blue,
      textColor: Colors.white,
    ); */
  }

  void _onChangeThemeMode(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();
    final currentState = settingsBloc.state;

    if (currentState.status == SettingsStatus.loading) return;

    final currentTheme = currentState.settings?.themeMode ?? ThemeMode.system;

    ThemeOptionBottomSheet.show(context, currentTheme, settingsBloc);
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Gap(10),
            const _SectionTitle(title: 'Account', toUpperCase: true),
            _SettingsCard(
              items: [
                SettingsItem(
                  icon: Icons.person,
                  title: 'Profile',
                  subTitle: 'Manage your profile',
                  onTap: () => _onTap(context),
                ),
                SettingsItem(
                  icon: Icons.shield,
                  title: 'Security',
                  subTitle: 'Password, 2FA, Biometrics',
                  onTap: () => _onTap(context),
                ),
              ],
            ),
            const Gap(10),
            const _SectionTitle(title: 'Preferences', toUpperCase: true),
            _SettingsCard(
              items: [
                SettingsItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subTitle: 'Budget alerts, reminders',
                  onTap: () => _onTap(context),
                ),
                SettingsItem(
                  icon: Icons.attach_money,
                  title: 'Currency',
                  trailingText: 'USD',
                  onTap: () => _onTap(context),
                ),
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    final themeText = state.status == SettingsStatus.success
                        ? _getThemeText(
                            state.settings?.themeMode ?? ThemeMode.system,
                          )
                        : 'System';

                    return SettingsItem(
                      icon: Icons.dark_mode,
                      title: 'Appearance',
                      trailingText: themeText,
                      onTap: () => _onChangeThemeMode(context),
                    );
                  },
                ),
              ],
            ),

            const Gap(10),
            const _SectionTitle(title: 'Data & privacy', toUpperCase: true),

            _SettingsCard(
              items: [
                SettingsItem(
                  icon: Icons.file_download,
                  title: 'Export data',
                  onTap: () => _onTap(context),
                ),
                SettingsItem(
                  icon: Icons.shield_moon_sharp,
                  title: 'Privacy Policy',
                  onTap: () => _onTap(context),
                ),
              ],
            ),
            const Gap(10),
            const _SectionTitle(title: 'Support', toUpperCase: true),

            _SettingsCard(
              items: [
                SettingsItem(
                  icon: Icons.info,
                  title: 'About',
                  onTap: () => _onTap(context),
                ),
                SettingsItem(
                  icon: Icons.question_mark,
                  title: 'FAQ',
                  onTap: () => _onTap(context),
                ),
              ],
            ),
            const Gap(20),
            _LogoutButton(),
            const Gap(20),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool toUpperCase;
  const _SectionTitle({required this.title, this.toUpperCase = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        toUpperCase ? title.toUpperCase() : title,
        style: context.textTheme.titleMedium,
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(50),
        ),
        child: TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout, color: Colors.red),
          label: Text(
            'Log Out',
            style: context.textTheme.titleMedium?.copyWith(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (final item in items) ...[
            item,
            if (items.indexOf(item) < items.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.grey.shade200,
              ),
          ],
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subTitle;
  final String? trailingText;
  final VoidCallback? onTap;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subTitle,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue, size: 22),
      ),
      title: Text(title),
      subtitle: subTitle != null ? Text(subTitle ?? '') : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(trailingText ?? ''),
            ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
