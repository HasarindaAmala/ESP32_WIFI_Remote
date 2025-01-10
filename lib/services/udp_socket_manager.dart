/*
* Author      : Manodya Rasanjana <manodya@srqrobotics.com>
* Company     : SRQ Robotics, Sri Lanka.
* Website     : https://www.srqrobotics.com/
* Version     : 1.0.0
* Date        : December 11, 2023
* Description : A custom class with flutter UDP communication functions
*/

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:udp/udp.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;

class UDPSocketManager {
  late UDP _udpSender; // UDP sending socket
  late UDP _udpReceiver; // UDP receiving socket
  late Endpoint _udpDestination; //
  late InternetAddress _udpIpAddress; // converted IpV4 address
  late Port _udpPort; //  converted UDP port

  bool _isIpAddressValid = false; // true if provided Ip address is valid
  bool _isPortNumberValid = false; // true if provided port number is valid
  bool _isWifiConnected = false; // true if connected to a wifi network

  bool _senderUdpInitialized = false; // true if enabled the sender socket
  bool _receiverUdpInitialized = false; // true if enabled the receiver socket
  bool _udpDestinationResponding = false; // true if replies are receiving
  String _latestReceivedData = ""; // latest data string received

  // receiver timeout. A temporary timer attached to avoid null errors
  Timer _udpReceiverTimer = Timer(const Duration(milliseconds: 100), () {});

  static UDPSocketManager? _instance; // singleton instance
  UDPSocketManager._();

  /// provides the instance of the class
  ///
  /// Example:
  /// ```dart
  /// UDPSocketManager udpSocketManager = UDPSocketManager.instance;
  /// ```
  static UDPSocketManager get instance {
    _instance ??= UDPSocketManager._();
    return _instance!;
  }

  //-------------------------------------
  // validation functions
  //-------------------------------------

  // return true if provided String is a valid IpV4 address
  bool validateIpV4Address({required String ipAddress}) {
    final RegExp ipv4Regex = RegExp(
        r'^(25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)$');
    return (ipv4Regex.hasMatch(ipAddress));
  }

  // return true if provided int is valid IpV4 UDP port number
  bool validateUDPPortNumber({required int udpPort}) {
    return (udpPort >= 0 && udpPort <= 65535);
  }

  // convert String and int data to usable UDP credentials
  // return true if validation stage succeeded
  bool _validateAndConvertUDPCredentials(
      {required String ipAddress, required int udpPort}) {
    _isIpAddressValid = validateIpV4Address(ipAddress: ipAddress);
    _isPortNumberValid = validateUDPPortNumber(udpPort: udpPort);

    if (_isIpAddressValid && _isPortNumberValid) {
      _udpIpAddress = InternetAddress(ipAddress);
      _udpPort = Port(udpPort);
      _udpDestination = Endpoint.unicast(_udpIpAddress, port: _udpPort);
      return true;
    } else {
      return false;
    }
  }

  // return true if the device connected to a WiFi network
  Future<bool> validateWiFiConnected() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    _isWifiConnected =
    (connectivityResult == ConnectivityResult.wifi) ? true : false;
    return _isWifiConnected;
  }

  //-------------------------------------
  // communication functions
  //-------------------------------------

  Future<bool> openUDPPorts(
      {required String ipAddress,
        required int udpPort,
        required int timeoutMillis}) async {
    // to ensure any previous UDP ports are not open
    closeUDPPorts();

    // verify and convert credentials before open the UDP sockets
    bool validationSucceed = _validateAndConvertUDPCredentials(
      ipAddress: ipAddress,
      udpPort: udpPort,
    );

    if (validationSucceed) {
      // open UDP sender socket
      try {
        _udpSender = await UDP.bind(Endpoint.any(port: _udpPort));
        _senderUdpInitialized = true;
      } catch (e) {
        _senderUdpInitialized = false;
      }

      //open UDP receiver socket, bind a listener, and setup timeout
      try {
        _udpReceiver = await UDP.bind(Endpoint.any(port: _udpPort));
        _resetUdpReceiverTimeout(timeoutMillis);

        _udpReceiver.asStream().listen((datagram) {
          if (datagram != null) {
            _handleReceivedUDPMessage(datagram, timeoutMillis);
          }
        });
        _receiverUdpInitialized = true;
      } catch (e) {
        _receiverUdpInitialized = false;
      }
    } else {
      _senderUdpInitialized = false;
      _receiverUdpInitialized = false;
    }
    return _senderUdpInitialized && _receiverUdpInitialized;
  }

  void _handleReceivedUDPMessage(Datagram datagram, int receiverTimeoutMillis) {
    _latestReceivedData = String.fromCharCodes(datagram.data);
    _udpDestinationResponding = true;

    // reset timeout timer everytime a message is received
    _resetUdpReceiverTimeout(receiverTimeoutMillis);
  }

  void closeUDPPorts() {
    // close receiverTimeout timer
    _udpReceiverTimer.cancel();

    // close sender UDP socket
    if (_senderUdpInitialized && _udpSender.socket != null) {
      _udpSender.close();
    }

    // close receiver UDP socket
    if (_receiverUdpInitialized && _udpReceiver.socket != null) {
      _udpReceiver.close();
    }

    // reset flags and variables
    _senderUdpInitialized = false;
    _receiverUdpInitialized = false;
    _udpDestinationResponding = false;
    _latestReceivedData = "";
  }

  Future<bool> udpSendJSONData(
      {required Map<String, dynamic> jsonMapToSend}) async {
    bool encodeSucceeded = false;
    bool sendSucceeded = false;
    String jsonString = '';

    try {
      jsonString = jsonEncode(jsonMapToSend);
      encodeSucceeded = true;
    } catch (e) {
      encodeSucceeded = false;
    }

    if (encodeSucceeded) {
      sendSucceeded = await udpSendStringData(dataToSend: jsonString);
    }

    return encodeSucceeded && sendSucceeded;
  }

  Future<bool> udpSendMessagePackData(
      {required Map<String, dynamic> messagePackMapToSend}) async {
    bool encodeSucceeded = false;
    bool sendSucceeded = false;
    Uint8List? msgPackString;

    try {
      msgPackString = msgpack.serialize(messagePackMapToSend);
      encodeSucceeded = true;
    } catch (e) {
      encodeSucceeded = false;
    }

    if (encodeSucceeded && msgPackString != null) {
      sendSucceeded = await udpSendUInt8ListData(dataToSend: msgPackString);
    }

    return encodeSucceeded && sendSucceeded;
  }

  Future<bool> udpSendUInt8ListData({required Uint8List dataToSend}) async {
    bool succeed = false;
    if (_senderUdpInitialized && _udpSender.socket != null) {
      try {
        int ret = await _udpSender.send(dataToSend, _udpDestination);
        succeed = (ret == -1) ? false : true;
      } catch (e) {
        succeed = false;
      }
    } else {
      succeed = false;
    }
    return succeed;
  }

  Future<bool> udpSendStringData({required String dataToSend}) async {
    bool succeed = false;
    if (_senderUdpInitialized && _udpSender.socket != null) {
      try {
        final sendData = Uint8List.fromList(dataToSend.codeUnits);
        int ret = await _udpSender.send(sendData, _udpDestination);
        succeed = (ret == -1) ? false : true;
      } catch (e) {
        succeed = false;
      }
    } else {
      succeed = false;
    }
    return succeed;
  }

// timer handling function to detect receiver timeout
  void _resetUdpReceiverTimeout(int receiverTimeoutMillis) {
    _udpReceiverTimer.cancel();

    _udpReceiverTimer =
        Timer(Duration(milliseconds: receiverTimeoutMillis), () {
          _udpDestinationResponding = false;
        });
  }

//-------------------------------------
// getter functions
//-------------------------------------
  String getUDPReceivedString() {
    return _latestReceivedData;
  }

  Map<String, dynamic> getUDPReceivedJSON() {
    try {
      final receivedJson = json.decode(_latestReceivedData);

      if (receivedJson is Map<String, dynamic>) {
        receivedJson["valid"] = 1;
        return receivedJson;
      } else {
        return {"valid": 0};
      }
    } catch (e) {
      return {"valid": 0};
    }
  }

  Map<dynamic, dynamic> getUDPReceivedMsgPack() {
    try {
      final List<int> extractedIntegers = _latestReceivedData
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((e) => int.parse(e.trim()))
          .toList();

      final receivedMsgPack =
      msgpack.Deserializer(Uint8List.fromList(extractedIntegers)).decode();

      if (receivedMsgPack is Map<dynamic, dynamic>) {
        receivedMsgPack["valid"] = 1;
        return receivedMsgPack;
      } else {
        return {"valid": 0};
      }
    } catch (e) {
      return {"valid": 0};
    }
  }

  bool getUDPRespondingStatus() {
    return _udpDestinationResponding;
  }

  bool getSenderUDPSocketStatus() {
    return _senderUdpInitialized;
  }

  bool getReceiverUDPSocketStatus() {
    return _receiverUdpInitialized;
  }

  bool getUDPSocketsStatus() {
    return _senderUdpInitialized && _receiverUdpInitialized;
  }
}
