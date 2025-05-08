import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:neo/neo.dart';

import 'neo_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class NeoRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        CustomRoute(
          path: "/",
          page: SidebarLayout.page,
          initial: true,
          children: [
            CustomRoute(
              path: "dashboard",
              page: DashboardRoute.page,
              initial: true,
            ),
            CustomRoute(
              path: "products",
              page: ProductsRoute.page,
            ),
            CustomRoute(
              path: "settings",
              page: SettingsRoute.page,
            ),
          ],
        ),
        RedirectRoute(
          path: "*",
          redirectTo: "/",
        ),
      ];
}

class MyObserver extends AutoRouterObserver {
  final WidgetRef ref;

  MyObserver(this.ref);

  String _formatRouteName(String routeName) => routeName.replaceAll('Route', '').replaceAll(RegExp(r'(?=[A-Z])'), ' ').trim();

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route.settings.name != null) {
      Future.microtask(() {
        ref.read(neoCurrentSidebarStatesProvider.notifier).setActiveItem(_formatRouteName(route.settings.name!));
      });
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute?.settings.name != null) {
      Future.microtask(() {
        ref.read(neoCurrentSidebarStatesProvider.notifier).setActiveItem(_formatRouteName(previousRoute!.settings.name!));
      });
    }
    super.didPop(route, previousRoute);
  }
}
