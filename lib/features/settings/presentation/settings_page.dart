import 'package:fin_track_pro/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'blocs/settings_bloc/settings_bloc.dart';
import 'widgets/theme_option_bottom_sheet.dart';
import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/export_transactions_csv.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _onTap(BuildContext context) {
    AppSnackbar().show(context, context.l10n.comingSoon);
  }

  Future<void> _onExportData(BuildContext context) async {
    try {
      AppSnackbar().show(context, 'Exporting data...');
      await getIt<ExportTransactionsCsv>().call();
    } catch (e) {
      if (context.mounted) {
        AppSnackbar().error(context, 'Error exporting data');
      }
    }
  }

  void _onChangeThemeMode(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();
    final currentState = settingsBloc.state;

    if (currentState.status == SettingsStatus.loading) return;

    final currentTheme = currentState.settings?.themeMode ?? ThemeMode.system;

    ThemeOptionBottomSheet.show(context, currentTheme, settingsBloc);
  }

  String _getThemeText(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return context.l10n.light;
      case ThemeMode.dark:
        return context.l10n.dark;
      default:
        return context.l10n.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('settings_page'),
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Gap(10),
            _SectionTitle(title: context.l10n.account, toUpperCase: true),
            _SettingsCard(
              items: [
                SettingsItem(
                  icon: Icons.person,
                  title: context.l10n.profile,
                  subTitle: context.l10n.manageYourProfile,
                  onTap: () => _onTap(context),
                ),
                SettingsItem(
                  icon: Icons.shield,
                  title: context.l10n.security,
                  subTitle: context.l10n.passwordBiometrics,
                  onTap: () => _onTap(context),
                ),
              ],
            ),
            const Gap(10),
            _SectionTitle(title: context.l10n.preferences, toUpperCase: true),
            _SettingsCard(
              items: [
                SettingsItem(
                  icon: Icons.notifications,
                  title: context.l10n.notifications,
                  subTitle: context.l10n.budgetAlertsReminders,
                  onTap: () => _onTap(context),
                ),
                SettingsItem(
                  icon: Icons.attach_money,
                  title: context.l10n.currency,
                  trailingText: 'COP',
                  onTap: () => _onTap(context),
                ),
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    final themeText =
                        state.status == SettingsStatus.success ||
                            state.status == SettingsStatus.initial
                        ? _getThemeText(
                            context,
                            state.settings?.themeMode ?? ThemeMode.system,
                          )
                        : context.l10n.system;

                    return SettingsItem(
                      icon: Icons.dark_mode,
                      title: context.l10n.appearance,
                      trailingText: themeText,
                      onTap: () => _onChangeThemeMode(context),
                    );
                  },
                ),
              ],
            ),

            const Gap(10),
            _SectionTitle(title: context.l10n.dataPrivacy, toUpperCase: true),

            _SettingsCard(
              items: [
                SettingsItem(
                  icon: Icons.file_download,
                  title: context.l10n.exportData,
                  onTap: () => _onExportData(context),
                ),
                SettingsItem(
                  icon: Icons.shield_moon_sharp,
                  title: context.l10n.privacyPolicy,
                  onTap: () => _onTap(context),
                ),
              ],
            ),
            const Gap(10),
            _SectionTitle(title: context.l10n.support, toUpperCase: true),

            _SettingsCard(
              items: [
                SettingsItem(
                  icon: Icons.info,
                  title: context.l10n.about,
                  onTap: () => _onTap(context),
                ),
                SettingsItem(
                  icon: Icons.question_mark,
                  title: context.l10n.faq,
                  onTap: () => _onTap(context),
                ),
              ],
            ),
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
