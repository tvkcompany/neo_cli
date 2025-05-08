import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:neo/neo.dart';

@RoutePage()
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(neoCurrentThemeProvider);

    return NeoSafeArea(
      child: Container(
        color: theme.colors.bgPrimary,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Settings",
                style: theme.textStyles.header1.copyWith(
                  color: theme.colors.fgPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
