import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:fin_track_pro/core/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _onTap() {
    AppSnackbar().show('Comming soon...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(10),
            const _SectionTitle(title: 'Account', toUpperCase: true),
            _SettingsCard(
              onTap: _onTap,
              items: [
                const SettingsItem(
                  icon: Icons.person,
                  title: 'Profile',
                  subTitle: 'Manage your profile',
                ),
                const SettingsItem(
                  icon: Icons.shield,
                  title: 'Security',
                  subTitle: 'Password, 2FA, Biometrics',
                ),
              ],
            ),

            const Gap(10),
            const _SectionTitle(title: 'Preferences', toUpperCase: true),
            _SettingsCard(
              onTap: _onTap,
              items: [
                const SettingsItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subTitle: 'Budget alerts, reminders',
                ),
                const SettingsItem(
                  icon: Icons.attach_money,
                  title: 'Currency',
                  trailingText: 'USD',
                ),
                const SettingsItem(
                  icon: Icons.dark_mode,
                  title: 'Appearance',
                  trailingText: 'System',
                ),
              ],
            ),

            const Gap(10),
            const _SectionTitle(title: 'Data & privacy', toUpperCase: true),
            _SettingsCard(
              onTap: _onTap,
              items: [
                const SettingsItem(
                  icon: Icons.file_download,
                  title: 'Export data',
                ),
                const SettingsItem(
                  icon: Icons.shield_moon_sharp,
                  title: 'Privacy Policy',
                ),
              ],
            ),

            const Gap(10),
            const _SectionTitle(title: 'Support', toUpperCase: true),
            _SettingsCard(
              onTap: _onTap,
              items: [
                const SettingsItem(icon: Icons.info, title: 'About'),
                const SettingsItem(icon: Icons.question_mark, title: 'FAQ'),
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

class _SettingsCard extends StatelessWidget {
  final List<SettingsItem> items;
  final VoidCallback onTap;
  const _SettingsCard({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (final setting in items) ...[
            _SettingsRow(item: setting, onTap: onTap),
            if (items.indexOf(setting) < items.length - 1)
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
        style: TextStyle(
          color: context.colorScheme.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final SettingsItem item;
  final VoidCallback onTap;
  const _SettingsRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(item.icon, color: Colors.blue, size: 22),
      ),
      title: Text(item.title),
      subtitle: item.subTitle != null ? Text(item.subTitle ?? '') : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (item.trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(item.trailingText ?? ''),
            ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
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
          label: const Text(
            'Log Out',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsItem {
  final IconData icon;
  final String title;
  final String? subTitle;
  final String? trailingText;

  const SettingsItem({
    required this.icon,
    required this.title,
    this.subTitle,
    this.trailingText,
  });
}
