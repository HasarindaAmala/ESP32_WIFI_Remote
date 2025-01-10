/*
* Author      : Manodya Rasanjana <manodya@srqrobotics.com>
* Company     : SRQ Robotics, Sri Lanka.
* Website     : https://www.srqrobotics.com/
* Version     : 1.0.0
* Date        : December 19, 2023
* Description : A WiFi remote controller app with two joysticks and two button groups
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wifi_joystick_controller/pages/app_info_page.dart';
import 'package:wifi_joystick_controller/pages/app_settings_page.dart';
import 'package:wifi_joystick_controller/pages/joystick_page.dart';
import 'package:wifi_joystick_controller/pages/loading_page.dart';
import 'package:wifi_joystick_controller/services/custom_themes.dart';
import 'package:wifi_joystick_controller/services/data_variable_handler.dart';

void main() async {
  // get data handler class instance
  final DataVariableHandler dataVariableHandler = DataVariableHandler.instance;

  // ensuring we have an instance of the WidgetsBinding
  WidgetsFlutterBinding.ensureInitialized();

  // set only landscape mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
  ]);

  // initialize shared preferences
  await dataVariableHandler.initSharedPreferences(avoidPreviousInitState: true);

  // get theme preference
  bool darkThemeSaved = dataVariableHandler.getDarkModePreferences();

  runApp(ChangeNotifierProvider(
    create: (BuildContext context) =>
        CustomThemeProvider(darkMode: darkThemeSaved),
    child: const WiFiJoystickControllerApp(),
  ));
}

class WiFiJoystickControllerApp extends StatelessWidget {
  const WiFiJoystickControllerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomThemeProvider>(
      builder: (context, customThemeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: customThemeProvider.getTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoadingScreen(),
            '/joystickScreen': (context) => const JoystickScreen(),
            '/appSettingsScreen': (context) => const AppSettingsScreen(),
            '/appInfoScreen': (context) => const AppInfoScreen(),
          },
        );
      },
    );
  }
}
