import 'package:auto_route/auto_route.dart';

import 'neo_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class NeoRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        CustomRoute(
          path: "/",
          page: WelcomeRoute.page,
          initial: true,
        ),
        RedirectRoute(
          path: "*",
          redirectTo: "/",
        ),
      ];
}
