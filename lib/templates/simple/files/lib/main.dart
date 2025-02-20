import 'package:flutter/widgets.dart';
import 'package:neo/neo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'router/neo_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final neoRouter = NeoRouter();

  NeoInitializer.initialize().then((_) {
    runApp(
      ProviderScope(
        child: NeoApp(
          title: "{{_PROJECT_NAME_}}",
          defaultThemeMode: NeoThemeMode.system,
          routerConfig: neoRouter.config(),
        ),
      ),
    );
  });
}
