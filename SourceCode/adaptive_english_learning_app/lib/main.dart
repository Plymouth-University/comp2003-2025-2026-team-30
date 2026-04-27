import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'services/app_language_service.dart';
import 'widgets/app_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AppLanguageService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const List<Locale> _supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('zh'),
    Locale('hi'),
    Locale('ar'),
    Locale('fr'),
    Locale('pt'),
    Locale('ru'),
    Locale('ja'),
    Locale('de'),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: AppLanguageService.instance.localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: _supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const AppGate(),
        );
      },
    );
  }
}
