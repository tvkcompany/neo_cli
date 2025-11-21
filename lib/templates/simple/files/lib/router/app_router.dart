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
      page: WelcomeRoute.page,
      initial: true,
    ),
    RedirectRoute(
      path: "*",
      redirectTo: "/",
    ),
  ];
}
