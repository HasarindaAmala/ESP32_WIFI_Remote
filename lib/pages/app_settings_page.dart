import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../services/custom_themes.dart';
import '../services/data_variable_handler.dart';
import '../services/udp_socket_manager.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final DataVariableHandler _dataVariableHandler = DataVariableHandler.instance;
  final UDPSocketManager _udpSocketManager = UDPSocketManager.instance;

  final TextEditingController _ipAddressController = TextEditingController();
  final TextEditingController _portNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) print("Settings screen init");
  }

  @override
  void dispose() {
    if (kDebugMode) print("Settings screen dispose");
    super.dispose();
  }

  bool _setIpAddress() {
    bool validated = _udpSocketManager.validateIpV4Address(
        ipAddress: _ipAddressController.text);

    if (validated) {
      _dataVariableHandler.setIpAddressUDP(_ipAddressController.text);
    } else {
      Fluttertoast.showToast(
        msg: "Error: Incorrect address. Please check again",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
      );
    }
    _ipAddressController.clear();
    return validated;
  }

  bool _setPortNumber() {
    late int _val;
    late bool _validated;

    try {
      _val = int.parse(_portNumberController.text);
      _validated = _udpSocketManager.validateUDPPortNumber(udpPort: _val);
    } catch (e) {
      _validated = false;
    }

    if (_validated) {
      _dataVariableHandler.setPortNumberUDP(_val);
    } else {
      Fluttertoast.showToast(
        msg: "Error: Please enter a value between 0 - 65535",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
      );
    }
    _portNumberController.clear();
    return _validated;
  }

  bool _setUdpTime(TextEditingController textEditingController) {
    late int _period;
    late bool _validated;

    try {
      _period = int.parse(textEditingController.text);
      _validated = _period >= 1 && _period <= 1000;
    } catch (e) {
      _validated = false;
    }

    if (_validated) {
      _dataVariableHandler.setUdpSendInterval(_period);
    } else {
      Fluttertoast.showToast(
        msg: "Error: Please enter a value between 1 - 1000 Millisecond",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
      );
    }

    textEditingController.clear();
    return _validated;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        Navigator.pushReplacementNamed(context, '/joystickScreen');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/joystickScreen');
            },
          ),
        ),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: const Text("General"),
              tiles: [
                _darkModeSettingsTile(),
                _keepScreenOnSettingsTile(),
              ],
            ),
            SettingsSection(
              title: const Text("UDP Credentials"),
              tiles: [
                _ipAddressSettingsTile(),
                _udpPortSettingsTile(),
              ],
            ),
            SettingsSection(
              title: const Text("UDP Communication"),
              tiles: [
                _comTimeSettingsTile(),
                _comBtnSettingsTile(),
              ],
            ),
            // SettingsSection(
            //   title: const Text("Joysticks"),
            //   tiles: [
            //     _joystickLimitedTouchSettingsTile(),
            //     _joystickStayPutSettingsTile(),
            //   ],
            // ),
            SettingsSection(
              title: const Text("Selection Button Groups"),
              tiles: [
                _chipGroup1SettingsTile(),
                _chipGroup2SettingsTile(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AbstractSettingsTile _darkModeSettingsTile() {
    return SettingsTile.switchTile(
      initialValue: _dataVariableHandler.getDarkModePreferences(),
      title: const Text("Dark mode"),
      leading: const Icon(Icons.dark_mode),
      onToggle: (bool value) {
        CustomThemeProvider themeProvider =
            Provider.of<CustomThemeProvider>(context, listen: false);
        setState(() {
          themeProvider.setTheme(value);
          _dataVariableHandler.setDarkModePreferences(value);
        });
      },
    );
  }

  AbstractSettingsTile _keepScreenOnSettingsTile() {
    return SettingsTile.switchTile(
      initialValue: _dataVariableHandler.getKeepScreenOn(),
      title: const Text("Keep screen turned-on"),
      leading: const Icon(Icons.settings_display),
      onToggle: (bool value) {
        setState(() {
          _dataVariableHandler.setKeepScreenOn(value);
        });
      },
    );
  }

  AbstractSettingsTile _ipAddressSettingsTile() {
    return SettingsTile.navigation(
      title: const Text("IP address"),
      trailing: const Icon(Icons.arrow_forward_ios),
      description: Text(_dataVariableHandler.getIpAddressUDP()),
      onPressed: (context) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: const Text("Set destination IP address"),
                content: TextField(
                  controller: _ipAddressController,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (_setIpAddress()) {
                        Navigator.of(context).pop();
                        setState(() {});
                      }
                    },
                    child: const Text("Set"),
                  ),
                  TextButton(
                    onPressed: () {
                      _ipAddressController.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  AbstractSettingsTile _udpPortSettingsTile() {
    return SettingsTile.navigation(
      title: const Text("Port number"),
      trailing: const Icon(Icons.arrow_forward_ios),
      description: Text(_dataVariableHandler.getPortNumberUDP().toString()),
      onPressed: (context) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: const Text("Set destination port number"),
                content: TextField(
                  controller: _portNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (_setPortNumber()) {
                        Navigator.of(context).pop();
                        setState(() {});
                      }
                    },
                    child: const Text("Set"),
                  ),
                  TextButton(
                    onPressed: () {
                      _portNumberController.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  AbstractSettingsTile _comTimeSettingsTile() {
    final TextEditingController _comTimeTxtController = TextEditingController();

    return SettingsTile.navigation(
      title: const Text("Data send interval"),
      trailing: const Icon(Icons.arrow_forward_ios),
      description: Text(
          "${_dataVariableHandler.getUdpSendInterval().toString()} millisecond"),
      onPressed: (context) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: const Text("Set data send interval (mS)"),
                content: TextField(
                  controller: _comTimeTxtController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (_setUdpTime(_comTimeTxtController)) {
                        Navigator.of(context).pop();
                        setState(() {});
                      }
                    },
                    child: const Text("Set"),
                  ),
                  TextButton(
                    onPressed: () {
                      _comTimeTxtController.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  AbstractSettingsTile _comBtnSettingsTile() {
    return SettingsTile.switchTile(
      initialValue: _dataVariableHandler.getComBtnLongPress(),
      title: const Text("Long press to trigger the connection button"),
      onToggle: (bool value) {
        setState(() {
          _dataVariableHandler.setComBtnLongPress(value);
        });
      },
    );
  }
  //
  // AbstractSettingsTile _joystickLimitedTouchSettingsTile() {
  //   return SettingsTile.navigation(
  //     title: const Text("Limited-touch mode"),
  //     trailing: const Icon(Icons.arrow_forward_ios),
  //     description: Text(_dataVariableHandler.getJoystickLimitedTouch()),
  //     onPressed: (context) {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: const Text("Set Limited-Touch Mode"),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   RadioListTile(
  //                     title: const Text("None"),
  //                     value: "None",
  //                     groupValue:
  //                         _dataVariableHandler.getJoystickLimitedTouch(),
  //                     onChanged: (String? value) {
  //                       _dataVariableHandler
  //                           .setJoystickLimitedTouch(value ?? "None");
  //                       setState(() {
  //                         Navigator.of(context).pop();
  //                       });
  //                     },
  //                     contentPadding: EdgeInsets.zero,
  //                   ),
  //                   RadioListTile(
  //                     title: const Text("Left Only"),
  //                     value: "Left Only",
  //                     groupValue:
  //                         _dataVariableHandler.getJoystickLimitedTouch(),
  //                     onChanged: (String? value) {
  //                       _dataVariableHandler
  //                           .setJoystickLimitedTouch(value ?? "Left Only");
  //                       setState(() {
  //                         Navigator.of(context).pop();
  //                       });
  //                     },
  //                     contentPadding: EdgeInsets.zero,
  //                   ),
  //                   RadioListTile(
  //                     title: const Text("Right Only"),
  //                     value: "Right Only",
  //                     groupValue:
  //                         _dataVariableHandler.getJoystickLimitedTouch(),
  //                     onChanged: (String? value) {
  //                       _dataVariableHandler
  //                           .setJoystickLimitedTouch(value ?? "Right Only");
  //                       setState(() {
  //                         Navigator.of(context).pop();
  //                       });
  //                     },
  //                     contentPadding: EdgeInsets.zero,
  //                   ),
  //                   RadioListTile(
  //                     title: const Text("Both"),
  //                     value: "Both",
  //                     groupValue:
  //                         _dataVariableHandler.getJoystickLimitedTouch(),
  //                     onChanged: (String? value) {
  //                       _dataVariableHandler
  //                           .setJoystickLimitedTouch(value ?? "Both");
  //                       setState(() {
  //                         Navigator.of(context).pop();
  //                       });
  //                     },
  //                     contentPadding: EdgeInsets.zero,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  AbstractSettingsTile _joystickStayPutSettingsTile() {
    return SettingsTile.navigation(
      title: const Text("Stay-put mode"),
      trailing: const Icon(Icons.arrow_forward_ios),
      description: Text(_dataVariableHandler.getJoystickStayPut()),
      onPressed: (context) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Set Stay-Put Mode"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile(
                      title: const Text("None"),
                      value: "None",
                      groupValue: _dataVariableHandler.getJoystickStayPut(),
                      onChanged: (String? value) {
                        _dataVariableHandler
                            .setJoystickStayPut(value ?? "None");
                        setState(() {
                          Navigator.of(context).pop();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile(
                      title: const Text("Left Only"),
                      value: "Left Only",
                      groupValue: _dataVariableHandler.getJoystickStayPut(),
                      onChanged: (String? value) {
                        _dataVariableHandler
                            .setJoystickStayPut(value ?? "Left Only");
                        setState(() {
                          Navigator.of(context).pop();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile(
                      title: const Text("Right Only"),
                      value: "Right Only",
                      groupValue: _dataVariableHandler.getJoystickStayPut(),
                      onChanged: (String? value) {
                        _dataVariableHandler
                            .setJoystickStayPut(value ?? "Right Only");
                        setState(() {
                          Navigator.of(context).pop();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile(
                      title: const Text("Both"),
                      value: "Both",
                      groupValue: _dataVariableHandler.getJoystickStayPut(),
                      onChanged: (String? value) {
                        _dataVariableHandler
                            .setJoystickStayPut(value ?? "Both");
                        setState(() {
                          Navigator.of(context).pop();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  AbstractSettingsTile _chipGroup1SettingsTile() {
    return SettingsTile.switchTile(
      initialValue: _dataVariableHandler.getChipGroupMode(1),
      title: const Text("Group A multi-selection mode"),
      onToggle: (bool value) {
        bool val1 = value;
        bool val2 = _dataVariableHandler.getChipGroupMode(2);
        setState(() {
          _dataVariableHandler.setChipGroupMode(val1, val2);
        });
      },
    );
  }

  AbstractSettingsTile _chipGroup2SettingsTile() {
    return SettingsTile.switchTile(
      initialValue: _dataVariableHandler.getChipGroupMode(2),
      title: const Text("Group B multi-selection mode"),
      onToggle: (bool value) {
        bool val1 = _dataVariableHandler.getChipGroupMode(1);
        bool val2 = value;
        setState(() {
          _dataVariableHandler.setChipGroupMode(val1, val2);
        });
      },
    );
  }
}
