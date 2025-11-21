import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:neo/neo.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../router/app_router.gr.dart';

@RoutePage()
class SidebarLayout extends ConsumerWidget {
  const SidebarLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(neoCurrentThemeProvider);
    final neoSidebarCurrentStates = ref.watch(neoCurrentSidebarStatesProvider);

    return AutoRouter(
      builder: (context, child) {
        final router = AutoRouter.of(context);

        Widget buildSidebarButton({
          required String text,
          required String routePrefix,
          PhosphorIconData Function(PhosphorIconsStyle)? icon,
          String? badgeText,
          Color? badgeColor,
          required VoidCallback onPressed,
        }) {
          final isActive = router.currentPath.toLowerCase().startsWith("/${routePrefix.toLowerCase()}");
          return NeoSidebarButton(
            label: text,
            isActive: isActive,
            icon: icon,
            badgeText: badgeText,
            badgeColor: badgeColor,
            onPressed: onPressed,
          );
        }

        return NeoSidebarLayout(
          sidebarChildren: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhosphorIcon(PhosphorIconsDuotone.floppyDisk, size: 40, color: theme.colors.fgPrimary),
                if (!neoSidebarCurrentStates.hideText) ...[
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: theme.spacings.extraSmall),
                      child: Text(
                        "Neo",
                        style: theme.textStyles.header1.copyWith(color: theme.colors.fgPrimary, fontSize: 24),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Gap(theme.spacings.large),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        buildSidebarButton(
                          text: "Dashboard",
                          routePrefix: "dashboard",
                          icon: PhosphorIcons.squaresFour,
                          onPressed: () {
                            NeoHaptics.light();
                            router.push(const DashboardRoute());
                          },
                        ),
                        Gap(theme.spacings.extraSmall),
                        buildSidebarButton(
                          text: "Products",
                          routePrefix: "products",
                          icon: PhosphorIcons.tag,
                          onPressed: () {
                            NeoHaptics.light();
                            router.push(const ProductsRoute());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Gap(theme.spacings.extraSmall),
            buildSidebarButton(
              text: "Settings",
              routePrefix: "settings",
              icon: PhosphorIcons.gear,
              onPressed: () {
                NeoHaptics.light();
                router.push(const SettingsRoute());
              },
            ),
          ],
          child: child,
        );
      },
    );
  }
}
