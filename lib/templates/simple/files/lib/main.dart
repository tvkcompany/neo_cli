import 'package:flutter/widgets.dart';
import 'package:neo/neo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'router/app_router.dart';

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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(routerProvider);

    return NeoApp(
      title: "{{_PROJECT_NAME_}}",
      defaultThemeMode: NeoThemeMode.system,
      routerConfig: appRouter.config(),
    );
  }
}
