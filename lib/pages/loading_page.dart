import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wifi_joystick_controller/services/data_variable_handler.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _showLoadingScreen();
  }

  void _showLoadingScreen() async {
    await _customSleep();

    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/joystickScreen');
  }

  Future<void> _customSleep() async {
    await Future.delayed(const Duration(milliseconds: 3000));
  }

  void _saveScreenDimensions() {
    DataVariableHandler dataVariableHandler = DataVariableHandler.instance;

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    double appBarHeight = 56.0; // default value for MaterialDesign
    double btnBarHeight = MediaQuery.of(context).viewPadding.bottom;

    dataVariableHandler.setScreenHeight(screenHeight);
    dataVariableHandler.setScreenWidth(screenWidth);
    dataVariableHandler.setStatusBarHeight(statusBarHeight);
    dataVariableHandler.setAppBarHeight(appBarHeight);
    dataVariableHandler.setBtnBarHeight(btnBarHeight);
  }

  @override
  Widget build(BuildContext context) {
    _saveScreenDimensions();

    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: SizedBox(
        width: width,
        height: height,
        child: Image(
          image: AssetImage("assets/splashScreen.png"),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
