/*
* Author      : Manodya Rasanjana <manodya@srqrobotics.com>
* Company     : SRQ Robotics, Sri Lanka.
* Website     : https://www.srqrobotics.com/
* Version     : 1.0.0
* Date        : December 11, 2023
* Description : A custom class for handle data of SRQ WiFi Joystick Controller app
*/

import 'package:shared_preferences/shared_preferences.dart';

class DataVariableHandler {
  //-------------------------------------
  // singleton instance
  //-------------------------------------
  static DataVariableHandler? _instance;

  DataVariableHandler._();

  static DataVariableHandler get instance {
    _instance ??= DataVariableHandler._();
    return _instance!;
  }

  //-------------------------------------
  // shared preferences functions
  //-------------------------------------
  late SharedPreferences _preferences;
  bool _sharedPreferencesInitialized = false;

  Future<void> initSharedPreferences(
      {required bool avoidPreviousInitState}) async {
    if (!_sharedPreferencesInitialized || avoidPreviousInitState) {
      _preferences = await SharedPreferences.getInstance();
      _sharedPreferencesInitialized = true;
    }
  }

  Future<void> clearSharedPreferencesInstance() async {
    if (_sharedPreferencesInitialized = true) await _preferences.clear();
  }

  //-------------------------------------
  // general app data handling functions
  //-------------------------------------

  // UDP communication related functions
  bool _isCommunicationEnabled = true;

  void setCommunicationStatus(bool setStatus) {
    _isCommunicationEnabled = setStatus;
  }

  bool getCommunicationStatus() {
    return _isCommunicationEnabled;
  }

  void setIpAddressUDP(String ipAddress) {
    _preferences.setString("userKey_ipAddressUDP", ipAddress);
  }

  String getIpAddressUDP() {
    String? ipAddressUDP = _preferences.getString("userKey_ipAddressUDP");
    return ipAddressUDP ?? '192.168.4.1';
  }

  void setPortNumberUDP(int port) {
    _preferences.setInt("userKey_portNumberUDP", port);
  }

  int getPortNumberUDP() {
    int? portNumberUDP = _preferences.getInt("userKey_portNumberUDP");
    return portNumberUDP ?? 8888;
  }

  void setUDPTimeoutInterval(int intervalMillis) {
    _preferences.setInt("userKey_UDPReceiverTimeout", intervalMillis);
  }

  int getUDPTimeoutInterval() {
    int? intervalMillis = _preferences.getInt("userKey_UDPReceiverTimeout");

    return (getUdpSendInterval() < 500)
        ? intervalMillis ?? 2000
        : intervalMillis ?? 3000;
  }

  // joystick page related functions

  int _joystickX1 = 0;
  int _joystickY1 = 0;
  int _joystickX2 = 0;
  int _joystickY2 = 0;

  int _chipGroup1 = 1;
  int _chipGroup2 = 1;

  bool _fullScreen = false;

  void setFlightMode(int modeNumber) {
    _preferences.setInt("userKey_flightMode", modeNumber);
  }

  int getFlightMode() {
    int? flightMode = _preferences.getInt("userKey_flightMode");
    return flightMode ?? 1;
  }

  void setJoystickX(int joystickNumber, int xVal) {
    if (joystickNumber == 1) _joystickX1 = xVal;
    if (joystickNumber == 2) _joystickX2 = xVal;
  }

  int getJoystickX(int joystickNumber) {
    if (joystickNumber == 1) return _joystickX1;
    if (joystickNumber == 2) return _joystickX2;
    return 0;
  }

  void setJoystickY(int joystickNumber, int yVal) {
    if (joystickNumber == 1) _joystickY1 = yVal;
    if (joystickNumber == 2) _joystickY2 = yVal;
  }

  int getJoystickY(int joystickNumber) {
    if (joystickNumber == 1) return _joystickY1;
    if (joystickNumber == 2) return _joystickY2;
    return 0;
  }

  void setJoystickStayPut(String mode) {
    _preferences.setString("userKey_jsStayPut", mode);
  }

  String getJoystickStayPut() {
    String? mode = _preferences.getString("userKey_jsStayPut");
    return mode ?? "None";
  }

  void setJoystickLimitedTouch(String mode) {
    _preferences.setString("userKey_jsLimitedTouch", mode);
  }

  String getJoystickLimitedTouch() {
    String? mode = _preferences.getString("userKey_jsLimitedTouch");
    return mode ?? "Both";
  }

  void setChipGroupVal(int chipGroup, int val) {
    switch (chipGroup) {
      case 1:
        _chipGroup1 = val;
        break;

      case 2:
        _chipGroup2 = val;
    }
  }

  int getChipGroupVal(int chipGroup) {
    switch (chipGroup) {
      case 1:
        return _chipGroup1;

      case 2:
        return _chipGroup2;

      default:
        return 0;
    }
  }

  void setChipGroupMode(bool multiSelect1, bool multiSelect2) {
    int _modeVal = 0;

    if (!multiSelect1 && !multiSelect2) {
      _modeVal = 0;
    } else if (!multiSelect1 && multiSelect2) {
      _modeVal = 1;
    } else if (multiSelect1 && !multiSelect2) {
      _modeVal = 2;
    } else if (multiSelect1 && multiSelect2) {
      _modeVal = 3;
    }

    _preferences.setInt("userKey_chipsMode", _modeVal);
  }

  // true if multiSelect
  bool getChipGroupMode(int chipGroup) {
    int? _modeVal = _preferences.getInt("userKey_chipsMode");

    if (chipGroup == 1) {
      _modeVal ??= 0;
    } else {
      _modeVal ??= 1;
    }

    if (chipGroup == 1) {
      return (_modeVal == 2 || _modeVal == 3) ? true : false;
    } else if (chipGroup == 2) {
      return (_modeVal == 1 || _modeVal == 3) ? true : false;
    }
    return false;
  }

  void setFullScreen(bool fullScreen) {
    _fullScreen = fullScreen;
  }

  bool getFullScreen() {
    return _fullScreen;
  }

  void setKeepScreenOn(bool keepOn) {
    _preferences.setBool("userKey_screenOn", keepOn);
  }

  bool getKeepScreenOn() {
    bool? keepOn = _preferences.getBool("userKey_screenOn");
    return keepOn ?? false;
  }

  void setComBtnLongPress(bool longPress) {
    _preferences.setBool("userKey_comBtnLP", longPress);
  }

  bool getComBtnLongPress() {
    bool? longPress = _preferences.getBool("userKey_comBtnLP");
    return longPress ?? false;
  }

  void setUdpSendInterval(int timePeriod_ms) {
    if (timePeriod_ms < 1) timePeriod_ms = 1;
    if (timePeriod_ms > 1000) timePeriod_ms = 1000;

    _preferences.setInt("userKey_udpPeriod", timePeriod_ms);
  }

  int getUdpSendInterval() {
    int? period = _preferences.getInt("userKey_udpPeriod");
    return period ?? 50;
  }

  // general app related functions
  double _screenHeight = 0.0;
  double _screenWidth = 0.0;
  double _statusBarHeight = 0.0;
  double _appbarHeight = 0.0;
  double _btnBarHeight = 0.0;

  void setDarkModePreferences(bool isDarkModeEnabled) {
    _preferences.setBool("userKey_darkMode", isDarkModeEnabled);
  }

  bool getDarkModePreferences() {
    bool? isDarkModeEnabled = _preferences.getBool("userKey_darkMode");
    return isDarkModeEnabled ?? false;
  }

  void setScreenHeight(double height) {
    _screenHeight = height;
  }

  double getScreenHeight() {
    return _screenHeight;
  }

  void setScreenWidth(double width) {
    _screenWidth = width;
  }

  double getScreenWidth() {
    return _screenWidth;
  }

  void setStatusBarHeight(double height) {
    _statusBarHeight = height;
  }

  double getStatusBarHeight() {
    return _statusBarHeight;
  }

  void setAppBarHeight(double height) {
    _appbarHeight = height;
  }

  double getBtnBarHeight() {
    return _btnBarHeight;
  }

  void setBtnBarHeight(double height) {
    _btnBarHeight = height;
  }

  double getAppBarHeight() {
    return _appbarHeight;
  }
}
