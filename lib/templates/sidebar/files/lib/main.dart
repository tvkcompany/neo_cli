import 'package:flutter/widgets.dart';
import 'package:neo/neo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'router/neo_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NeoInitializer.initialize().then((_) {
    runApp(
      ProviderScope(
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  final neoRouter = NeoRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NeoApp(
      title: "{{_PROJECT_NAME_}}",
      defaultThemeMode: NeoThemeMode.system,
      routerConfig: neoRouter.config(),
    );
  }
}
