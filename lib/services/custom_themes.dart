import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data_variable_handler.dart';

// a class to set themes and change their properties
class CustomThemeProvider extends ChangeNotifier {
  final DataVariableHandler dataVariableHandler = DataVariableHandler.instance;
  late ThemeData _selectedTheme;

  ThemeData darkTheme = ThemeData.dark().copyWith(
    dialogTheme: const DialogTheme(
      surfaceTintColor: Color(0xFF1C1C1C),
      backgroundColor: Color(0xFF1C1C1C),
    ),
    scaffoldBackgroundColor: Color(0xFF1C1C1C),
    colorScheme: const ColorScheme.dark(),
    primaryColor: Colors.black,
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      color: Color(0xFF2E2E2E),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1C1C1C),
        systemNavigationBarColor: Color(0xFF151515),
      ),
    ),
  );

  ThemeData lightTheme = ThemeData.light().copyWith(
    dialogTheme: const DialogTheme(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(),
    primaryColor: Colors.white,
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.normal,
      ),
      toolbarTextStyle: TextStyle(
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      color: Color(0xFF2E2E2E),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1C1C1C),
        systemNavigationBarColor: Color(0xFF151515),
      ),
    ),
  );

  CustomThemeProvider({required bool darkMode}) {
    _selectedTheme = darkMode ? darkTheme : lightTheme;
  }

  ThemeData get getTheme => _selectedTheme;

  bool get isDarkTheme => _selectedTheme == darkTheme;

  void setTheme(bool setDarkTheme) {
    _selectedTheme = setDarkTheme ? darkTheme : lightTheme;
    dataVariableHandler.setDarkModePreferences(setDarkTheme);
    notifyListeners();
  }
}

// a switch widget to change between dark and light themes
class ThemeButtonWidget extends StatelessWidget {
  const ThemeButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomThemeProvider themeProvider =
    Provider.of<CustomThemeProvider>(context);
    return Switch.adaptive(
        value: themeProvider.isDarkTheme,
        onChanged: (value) {
          themeProvider.setTheme(value);
        });
  }
}
