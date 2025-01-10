import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../components/chip_group.dart';
import '../components/joystick_flutter.dart';
import '../components/popup_menu.dart';
import '../services/data_variable_handler.dart';
import '../services/udp_socket_manager.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
class JoystickScreen extends StatefulWidget {
  const JoystickScreen({Key? key}) : super(key: key);

  @override
  State<JoystickScreen> createState() => _JoystickScreenState();
}

class _JoystickScreenState extends State<JoystickScreen>
    with WidgetsBindingObserver {
  // objects of helper classes
  final DataVariableHandler _dataVariableHandler = DataVariableHandler.instance;
  final UDPSocketManager _udpSocketManager = UDPSocketManager.instance;

  // page visibility status variable
  bool _inForeground = true;

  // message sending timer. A temporary timer attached to avoid exceptions
  Timer _udpMsgTimer = Timer(const Duration(milliseconds: 100), () {});

  @override
  void initState() {
    super.initState();
    if (kDebugMode) print("Joystick screen init");

    // binding widget to observer to get the visibility status
    WidgetsBinding.instance.addObserver(this);

    // enable always on display mode if necessary
    if (_dataVariableHandler.getKeepScreenOn()) WakelockPlus.enable();

    // start communication if the user hasn't disabled it before
    if (_dataVariableHandler.getCommunicationStatus()) _startCommunication();
  }

  @override
  void dispose() {
    // disable UDP communication
    _terminateCommunication();

    // no longer need to keep the screen enabled
    WakelockPlus.disable();

    // no longer need to get visibility status
    WidgetsBinding.instance.removeObserver(this);

    if (kDebugMode) print("Joystick screen dispose");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // these methods are more or less same as the init and dispose function methods

    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) print("Joystick screen foreground");

      if (_dataVariableHandler.getKeepScreenOn()) WakelockPlus.enable();
      setState(() {
        _inForeground = true;
      });
    } else {
      if (kDebugMode) print("Joystick screen background");

      WakelockPlus.disable();
      setState(() {
        _inForeground = false;
      });
    }
  }

  void _startCommunication() {
    // get UDP send interval
    final int udpInterval = _dataVariableHandler.getUdpSendInterval();

    // open UDP ports
    _initUdp();

    // close UDP timer to ensure there are no any previously attached timers
    _udpMsgTimer.cancel();

    _udpMsgTimer =
        Timer.periodic(Duration(milliseconds: udpInterval), (Timer timer) {
      _udpSendMsg();
    });

    // communication enabled and status is true now
    _dataVariableHandler.setCommunicationStatus(true);
  }

  void _pauseCommunication() {
    // close the UDP message sending timer
    _udpMsgTimer.cancel();
  }

  void _terminateCommunication() {
    _pauseCommunication();
    _udpSocketManager.closeUDPPorts();
  }

  Future<void> _initUdp() async {
    // get UDP credentials
    String ipAddress = _dataVariableHandler.getIpAddressUDP();
    int portNumber = _dataVariableHandler.getPortNumberUDP();
    int portTimeout = _dataVariableHandler.getUDPTimeoutInterval();

    // open and init UDP ports
    await _udpSocketManager.openUDPPorts(
        ipAddress: ipAddress, udpPort: portNumber, timeoutMillis: portTimeout);

    // Show warning to the user if UDP init un-succeeded
    if (!_udpSocketManager.getUDPSocketsStatus()) {
      Fluttertoast.showToast(
        msg: "Error: Unable to open UDP sockets",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
      );
    }
  }

  void _udpSendMsg() {
    if (_inForeground && _udpSocketManager.getUDPSocketsStatus()) {
      Map<String, dynamic> jsonMapToSend = {
        'WJC': true, // validation tag
        'jsLx': _dataVariableHandler.getJoystickX(1), // left joystick X
        'jsLy': _dataVariableHandler.getJoystickY(1), // left joystick Y
        'jsRx': _dataVariableHandler.getJoystickX(2), // right joystick X
        'jsRy': _dataVariableHandler.getJoystickY(2), // right joystick Y
        'bgA': _dataVariableHandler.getChipGroupVal(1), // button group A value
        'bgmA': _dataVariableHandler.getChipGroupMode(1), // button group A mode
        'bgB': _dataVariableHandler.getChipGroupVal(2), // button group B value
        'bgmB': _dataVariableHandler.getChipGroupMode(2), // button group B mode
      };

      _udpSocketManager.udpSendJSONData(jsonMapToSend: jsonMapToSend);
    }
  }

  void _onCommunicationBtnPressed() {
    // toggle communication status
    if (_dataVariableHandler.getCommunicationStatus()) {
      _pauseCommunication();

      // communication paused and status is false now
      _dataVariableHandler.setCommunicationStatus(false);
    } else {
      _startCommunication();
    }
  }

  void _popupMenuActions(int menuItemNumber) {
    switch (menuItemNumber) {
      case 1:
        //_enterFullScreen();
        break;

      case 2:
        Navigator.pushReplacementNamed(context, '/appSettingsScreen');
        break;

      case 3:
        Navigator.pushReplacementNamed(context, '/appInfoScreen');
        break;
    }
  }

  // void _enterFullScreen() {
  //   // hide system status and navigation bars
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  //   setState(() {
  //     _dataVariableHandler.setFullScreen(true);
  //   });
  //
  //   Fluttertoast.showToast(
  //     msg: "Drag from top and touch the back button to exit full screen",
  //     toastLength: Toast.LENGTH_LONG,
  //     gravity: ToastGravity.BOTTOM,
  //     timeInSecForIosWeb: 5,
  //   );
  // }

  // void _onBackPressed(bool didPop) async {
  //   if (!didPop) {
  //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //         overlays: SystemUiOverlay.values);
  //     setState(() {
  //       _dataVariableHandler.setFullScreen(false);
  //     });
  //   }
  // }

  PreferredSizeWidget _customAppBar(CustomPopupMenuCallback onSelected) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return AppBar(

      backgroundColor: Color(0xFF1A1A2E),
      title: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: width*0.08,),
            Icon(Icons.settings_remote),
            SizedBox(width: width*0.02,),
            Text(
              "ESP WIFI REMOTE",
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            ),
            SizedBox(width: width*0.02,),
            Icon(Icons.settings_remote),
        
          ],
        ),
      ),
      actions: [
        CustomPopupMenuButton(
          onSelected: onSelected,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = _dataVariableHandler.getScreenHeight();
    double topBarHeight = _dataVariableHandler.getAppBarHeight() +
        _dataVariableHandler.getStatusBarHeight();

    return PopScope(
      canPop: _dataVariableHandler.getFullScreen() ? false : true,
      //onPopInvoked: _onBackPressed,
      child: Scaffold(
        appBar: _dataVariableHandler.getFullScreen()
            ? null
            : _customAppBar(_popupMenuActions),
        body: ScreenStack(
          stackHeight: _dataVariableHandler.getFullScreen()
              ? screenHeight
              : screenHeight - topBarHeight,
          dataHandler: _dataVariableHandler,
          udpHandler: _udpSocketManager,
          comBtnCallBack: _onCommunicationBtnPressed,
        ),
      ),
    );
  }
}

class ScreenStack extends StatelessWidget {
  final double stackHeight;
  final DataVariableHandler dataHandler;
  final UDPSocketManager udpHandler;
  final void Function() comBtnCallBack;

  const ScreenStack({
    Key? key,
    required this.stackHeight,
    required this.dataHandler,
    required this.udpHandler,
    required this.comBtnCallBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Stack(
      children: [
        Positioned.fill(
            child: Image(
              image: AssetImage("assets/joysticBackground.jpg"),
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.98),
            )),
        Positioned(
            top: 0.0,
            child: SizedBox(
              child: SizedBox(
                width: width,
                height: height * 0.5,
                child: Center(
                  child: SizedBox(
                      width: width * 0.18,
                      child: Image(
                        image: AssetImage("assets/bee.png"),
                        opacity: AlwaysStoppedAnimation(0.8),
                      )),
                ),
              ),
            )),
        SafeArea(
          child: Column(
            children: [
              SizedBox(height: height*0.02,),
              Expanded(
                flex: 18,
                child: CommunicationButtonStack(
                  dataHandler: dataHandler,
                  udpHandler: udpHandler,
                  comBtnPressed: comBtnCallBack,
                ),
              ),
              Expanded(
                flex: 95,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    JoystickStack(
                      height: stackHeight * 0.85,
                      dataHandler: dataHandler,
                    ),
                    ChipGroupsStack(
                      dataHandler: dataHandler,
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 7,
                child: SizedBox.expand(),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class JoystickStack extends StatefulWidget {
  final double height;
  final DataVariableHandler dataHandler;

  const JoystickStack({
    Key? key,
    required this.height,
    required this.dataHandler,
  }) : super(key: key);

  @override
  State<JoystickStack> createState() => _JoystickStackState();
}

class _JoystickStackState extends State<JoystickStack> {
  late bool _joystick1StayPut;
  late bool _joystick2StayPut;
  late bool _joystick1LimitedTouch;
  late bool _joystick2LimitedTouch;

  void _saveLeftJoystickValues(
       double x, double y) {
    widget.dataHandler.setJoystickX(1, x.round());
    widget.dataHandler.setJoystickY(1, y.round());
  }

  void _saveRightJoystickValues(
       double x, double y) {
    widget.dataHandler.setJoystickX(2, x.round());
    widget.dataHandler.setJoystickY(2, y.round());
  }

  @override
  void initState() {
    super.initState();
    if (kDebugMode) print("JoysTick stack init");

    _assignJoystickControllerValues();
  }

  @override
  void dispose() {
    if (kDebugMode) print("JoysTick stack dispose");
    super.dispose();
  }

  void _assignJoystickControllerValues() {
    String stayPut = widget.dataHandler.getJoystickStayPut();
    String limitedTouch = widget.dataHandler.getJoystickLimitedTouch();

    _joystick1StayPut = (stayPut == "Left Only" || stayPut == "Both");
    _joystick2StayPut = (stayPut == "Right Only" || stayPut == "Both");
    _joystick1LimitedTouch =
        (limitedTouch == "Left Only" || limitedTouch == "Both");
    _joystick2LimitedTouch =
        (limitedTouch == "Right Only" || limitedTouch == "Both");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Joystick(
          listener: (details) {
            setState(() {
              _saveLeftJoystickValues(details.x, details.y);
            });
          },
          base: SizedBox(
              width: width * 0.3,
              height: width * 0.3,
              child: Image(
                  image: AssetImage("assets/joysticBase.png"))),
          stick: Container(
            width: width * 0.075,
            height: width * 0.075,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF353536),
                border:
                Border.all(color: Color(0xFF1FBFFF), width: 4)),
          ),
        ),

        Joystick(
          listener: (details) {
            setState(() {
              _saveRightJoystickValues(details.x, details.y);
            });
          },
          base: SizedBox(
              width: width * 0.3,
              height: width * 0.3,
              child: Image(
                  image: AssetImage("assets/joysticBase.png"))),
          stick: Container(
            width: width * 0.075,
            height: width * 0.075,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF353536),
                border:
                Border.all(color: Color(0xFF1FBFFF), width: 4)),
          ),
        ),
        // Expanded(
        //   flex: 47,
        //   child: Container(
        //     alignment: Alignment.centerLeft,
        //     child: SRQJoystick(
        //       baseSize: widget.height,
        //       stickSize: widget.height * 0.35,
        //       stayPut: _joystick1StayPut,
        //       limitedTouch: _joystick1LimitedTouch,
        //       darkMode: widget.dataHandler.getDarkModePreferences(),
        //       onDirectionChanged: _saveLeftJoystickValues,
        //     ),
        //   ),
        // ),
        // Expanded(
        //   flex: 47,
        //   child: Container(
        //     alignment: Alignment.centerRight,
        //     child: SRQJoystick(
        //       baseSize: widget.height,
        //       stickSize: widget.height * 0.35,
        //       stayPut: _joystick2StayPut,
        //       limitedTouch: _joystick2LimitedTouch,
        //       darkMode: widget.dataHandler.getDarkModePreferences(),
        //       onDirectionChanged: _saveRightJoystickValues,
        //     ),
        //   ),
        // ),

      ],
    );
  }
}

class CommunicationButtonStack extends StatefulWidget {
  final DataVariableHandler dataHandler;
  final UDPSocketManager udpHandler;
  final void Function() comBtnPressed;

  const CommunicationButtonStack({
    Key? key,
    required this.dataHandler,
    required this.udpHandler,
    required this.comBtnPressed,
  }) : super(key: key);

  @override
  State<CommunicationButtonStack> createState() =>
      _CommunicationButtonStackState();
}

class _CommunicationButtonStackState extends State<CommunicationButtonStack> {
  // Button visible properties
  late String _btnText;
  late WidgetStateProperty<Color> _btnColor;
  late Color _btnTxtColor;

  late Timer _comBtnTimer = Timer(const Duration(milliseconds: 100), () {});
  late bool _longPressToTrigger;
  int _previousState = 0;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) print("Com btn stack init");

    _longPressToTrigger = widget.dataHandler.getComBtnLongPress();

    _setColor();
    _startComBtnTimer();
  }

  @override
  void dispose() {
    _stopComBtnTimer();

    if (kDebugMode) print("Com btn stack dispose");
    super.dispose();
  }

  void _startComBtnTimer() {
    _comBtnTimer.cancel();
    _comBtnTimer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer timer) {
      _setColor();
    });
  }

  void _stopComBtnTimer() {
    _comBtnTimer.cancel();
  }

  void _handleBtnPress() {
    widget.comBtnPressed();
    _setColor();
  }

  void _setColor() {
    int currentState = 0;

    if (widget.dataHandler.getCommunicationStatus()) {
      if (widget.udpHandler.getUDPRespondingStatus()) {
        currentState = 1;
      } else {
        currentState = 2;
      }
    } else {
      currentState = 3;
    }

    if (currentState != _previousState) {
      setState(() {
        if (currentState == 1) {
          _btnText = 'Connected';
          _btnColor = WidgetStateProperty.all<Color>(Colors.green);
          _btnTxtColor = Colors.white;
        } else if (currentState == 2) {
          _btnText = 'Connecting';
          _btnColor = WidgetStateProperty.all<Color>(Color(0xFF0B96CE));
          _btnTxtColor = Colors.white;
        } else if (currentState == 3) {
          _btnText = 'Disconnected';
          _btnColor = WidgetStateProperty.all<Color>(Colors.red);
          _btnTxtColor = Colors.white;
        }
      });
      _previousState = currentState;
      if (kDebugMode) print("ComBtn color changed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 78,
          child: SizedBox.expand(),
        ),
        Expanded(
          flex: 20,
          child: Container(
            alignment: Alignment.topRight,
            width: 20,
            child: ElevatedButton(
              onPressed: () {
                if (!_longPressToTrigger) _handleBtnPress();
              },
              onLongPress: () {
                if (_longPressToTrigger) _handleBtnPress();
              },
              style: ButtonStyle(
                backgroundColor: _btnColor,
                shape: WidgetStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              child: Text(
                _btnText,
                style: TextStyle(color: _btnTxtColor),
              ),
            ),
          ),
        ),
        const Expanded(
          flex: 2,
          child: SizedBox.expand(),
        )
      ],
    );
  }
}

class ChipGroupsStack extends StatefulWidget {
  final DataVariableHandler dataHandler;

  const ChipGroupsStack({
    Key? key,
    required this.dataHandler,
  }) : super(key: key);

  @override
  State<ChipGroupsStack> createState() => _ChipGroupsStackState();
}

class _ChipGroupsStackState extends State<ChipGroupsStack> {
  late bool _chipGroupAMultiSelect, _chipGroupBMultiSelect;

  @override
  void initState() {
    super.initState();

    // get single-select/ multi-select mode status
    _chipGroupAMultiSelect = widget.dataHandler.getChipGroupMode(1);
    _chipGroupBMultiSelect = widget.dataHandler.getChipGroupMode(2);

    // set initial values according to the mode
    if (_chipGroupAMultiSelect) {
      widget.dataHandler.setChipGroupVal(1, 0);
    } else {
      widget.dataHandler.setChipGroupVal(1, 1);
    }

    if (_chipGroupBMultiSelect) {
      widget.dataHandler.setChipGroupVal(2, 0);
    } else {
      widget.dataHandler.setChipGroupVal(2, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.0,
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          (_chipGroupAMultiSelect)
              ? MultiSelectionChipGroup(
                  onChipSelected: (int buttonIndex) {
                    widget.dataHandler.setChipGroupVal(1, buttonIndex);
                  },
                  prefix: 'A',
                )
              : SingleSelectionChipGroup(
                  onChipSelected: (int buttonIndex) {
                    widget.dataHandler.setChipGroupVal(1, buttonIndex);
                  },
                  prefix: 'A',
                ),
          (_chipGroupBMultiSelect)
              ? MultiSelectionChipGroup(
                  onChipSelected: (int buttonIndex) {
                    widget.dataHandler.setChipGroupVal(2, buttonIndex);
                  },
                  prefix: 'B',
                )
              : SingleSelectionChipGroup(
                  onChipSelected: (int buttonIndex) {
                    widget.dataHandler.setChipGroupVal(2, buttonIndex);
                  },
                  prefix: 'B',
                ),
        ],
      ),
    );
  }
}
