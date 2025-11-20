import 'package:auto_route/auto_route.dart';

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
