import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:neo/neo.dart';

@RoutePage()
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(neoCurrentThemeProvider);

    return CupertinoPageScaffold(
      child: NeoSafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome to Neo",
                style: theme.textStyles.header1.copyWith(
                  color: theme.colors.fgPrimary,
                ),
              ),
              Gap(theme.spacings.medium),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NeoButton(
                    variant: NeoButtonVariant.outlined,
                    text: "Learn more",
                    onPressed: () {},
                  ),
                  Gap(theme.spacings.small),
                  NeoButton(
                    variant: NeoButtonVariant.filled,
                    text: "Get started",
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
