import 'package:buzzby/src/components/buzz_page_loader.dart';
import 'package:buzzby/src/components/custom_theme_color.dart';
import 'package:buzzby/src/pages/buzzpage.dart';

import '../src/pages/home.dart';
import '../src/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return CustomThemeSeedBuilder(
      seedColor: Colors.green,
      child: ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) {
          debugPrint(
              'building with color ${CustomThemeSeedBuilder.of(context)}');
          return MaterialApp(
            // Providing a restorationScopeId allows the Navigator built by the
            // MaterialApp to restore the navigation stack when a user leaves and
            // returns to the app after it has been killed while running in the
            // background.
            restorationScopeId: 'app',

            // Provide the generated AppLocalizations to the MaterialApp. This
            // allows descendant Widgets to display the correct translations
            // depending on the user's locale.
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English, no country code
            ],

            // Use AppLocalizations to configure the correct application title
            // depending on the user's locale.
            //
            // The appTitle is defined in .arb files found in the localization
            // directory.
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,

            // Define a light and dark color theme. Then, read the user's
            // preferred ThemeMode (light, dark, or system default) from the
            // SettingsController to display the correct theme.
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  primary: CustomThemeSeed.of(context)
                      ?.customThemeSeedBuilderState
                      .seedColor,
                  seedColor: CustomThemeSeed.of(context)
                          ?.customThemeSeedBuilderState
                          .seedColor ??
                      Colors.purple),
              bottomSheetTheme: const BottomSheetThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
            ),
            // darkTheme: ThemeData.dark(),
            themeMode: settingsController.themeMode,

            // Define a function to handle named routes in order to support
            // Flutter web url navigation and deep linking.
            onGenerateRoute: (RouteSettings routeSettings) {
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  switch (routeSettings.name) {
                    case LoginScreen.routeName:
                      return const LoginScreen();

                    case HomeScreen.routeName:
                      return const HomeScreen();

                    case BuzzPage.routeName:
                      return BuzzPageLoader(
                          buzzId: routeSettings.arguments as int);

                    default:
                      return Supabase.instance.client.auth.currentUser == null
                          ? const LoginScreen()
                          : const HomeScreen();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
