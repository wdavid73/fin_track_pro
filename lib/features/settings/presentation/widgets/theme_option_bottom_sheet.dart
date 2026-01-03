import 'package:fin_track_pro/core/extensions/extensions.dart';
import 'package:fin_track_pro/features/settings/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ThemeOptionBottomSheet {
  static void show(
    BuildContext context,
    ThemeMode currentTheme,
    SettingsBloc settingsBloc,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Theme', style: context.textTheme.titleLarge),
            const Gap(16),
            _ThemeOption(
              title: 'System',
              isSelected: currentTheme == ThemeMode.system,
              onTap: () {
                settingsBloc.add(const ChangeThemeMode(ThemeMode.system));
                Navigator.pop(modalContext);
              },
            ),
            _ThemeOption(
              title: 'Light',
              isSelected: currentTheme == ThemeMode.light,
              onTap: () {
                settingsBloc.add(const ChangeThemeMode(ThemeMode.light));
                Navigator.pop(modalContext);
              },
            ),
            _ThemeOption(
              title: 'Dark',
              isSelected: currentTheme == ThemeMode.dark,
              onTap: () {
                settingsBloc.add(const ChangeThemeMode(ThemeMode.dark));
                Navigator.pop(modalContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const _ThemeOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: onTap,
    );
  }
}
