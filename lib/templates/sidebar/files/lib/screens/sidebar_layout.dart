import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:neo/neo.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../router/neo_router.gr.dart';

@RoutePage()
class SidebarLayout extends HookConsumerWidget {
  const SidebarLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(neoCurrentThemeProvider);
    final router = AutoRouter.of(context);

    final neoSidebarCurrentStates = ref.watch(neoCurrentSidebarStatesProvider);
    final activeItem = useState("Dashboard");

    Widget buildSidebarButton(
      String text, {
      PhosphorIconData Function(PhosphorIconsStyle)? icon,
      String? badgeText,
      Color? badgeColor,
      Function()? onPressed,
    }) {
      return NeoSidebarButton(
        label: text,
        isActive: activeItem.value == text,
        icon: icon,
        badgeText: badgeText,
        badgeColor: badgeColor,
        onPressed: onPressed ?? () {},
      );
    }

    return NeoSidebarLayout(
      sidebarChildren: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image.asset(
            //   "assets/images/logo.png",
            //   width: 40,
            //   height: 40,
            // ),
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
                      "Dashboard",
                      icon: PhosphorIcons.squaresFour,
                      onPressed: () {
                        if (activeItem.value != "Dashboard") {
                          NeoHaptics.light();
                          activeItem.value = "Dashboard";
                          router.push(const DashboardRoute());
                        }
                      },
                    ),
                    Gap(theme.spacings.extraSmall),
                    buildSidebarButton(
                      "Products",
                      icon: PhosphorIcons.tag,
                      onPressed: () {
                        if (activeItem.value != "Products") {
                          NeoHaptics.light();
                          activeItem.value = "Products";
                          router.push(const ProductsRoute());
                        }
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
          "Settings",
          icon: PhosphorIcons.gear,
          onPressed: () {
            if (activeItem.value != "Settings") {
              NeoHaptics.light();
              activeItem.value = "Settings";
              router.push(const SettingsRoute());
            }
          },
        ),
      ],
      child: const AutoRouter(),
    );
  }
}
