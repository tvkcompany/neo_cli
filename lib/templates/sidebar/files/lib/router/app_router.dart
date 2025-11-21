import 'package:auto_route/auto_route.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_router.gr.dart';
part 'app_router.g.dart';

@Riverpod(keepAlive: true)
AppRouter router(Ref ref) {
  return AppRouter(ref);
}

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  final Ref ref;

  AppRouter(this.ref);

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
