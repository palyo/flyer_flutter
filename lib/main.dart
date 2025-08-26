import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyer/presentation/theme/colors.dart';

import 'presentation/screens/screen_flyer_maker.dart';
import 'presentation/screens/screen_flyer_maker_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: colorAppBackground,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    return MaterialApp(
      title: 'AR Creation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: colorAppBackground,
        canvasColor: colorAppBackground,
        cardColor: colorAppCard,
        primaryColor: colorAppPrimary,
        useMaterial3: false,
        appBarTheme: AppBarTheme(
          backgroundColor: colorAppBackground,
          foregroundColor: colorAppText,
          centerTitle: false,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: colorAppBackground,
        canvasColor: colorAppBackground,
        cardColor: colorAppCard,
        primaryColor: colorAppPrimary,
        useMaterial3: false,
        appBarTheme: AppBarTheme(
          backgroundColor: colorAppBackground,
          foregroundColor: colorAppText,
          centerTitle: false,
        ),
      ),
      themeMode: ThemeMode.light,
      home: ScreenFlyerMakerBloc(),
    );
  }
}
