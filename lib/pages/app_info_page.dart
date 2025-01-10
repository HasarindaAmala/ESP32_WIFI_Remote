import 'dart:io' show Platform;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_joystick_controller/services/data_variable_handler.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  final DataVariableHandler _dataVariableHandler = DataVariableHandler.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    bool darkModeEn = _dataVariableHandler.getDarkModePreferences();
    double stackWidth = _dataVariableHandler.getScreenWidth() -
        _dataVariableHandler.getBtnBarHeight();
    double stackHeight = _dataVariableHandler.getScreenHeight() -
        (_dataVariableHandler.getAppBarHeight() +
            _dataVariableHandler.getStatusBarHeight());

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        Navigator.pushReplacementNamed(context, '/joystickScreen');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("About"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/joystickScreen');
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              height: stackHeight - 20,
              width: stackWidth - 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: darkModeEn ? Color(0xFF454545) : Color(0xFFD8D8D5),
              ),
              child: Row(
                children: [
                  LogoAndVersionSection(
                    darkMode: darkModeEn,
                  ),
                  VerticalDivider(
                    indent: 10,
                    endIndent: 10,
                    width: 10,
                    thickness: 1,
                    color: darkModeEn ? Color(0xFFD8D8D5) : Color(0xFF454545),
                  ),
                  AppDetailsSection(
                    width: stackWidth,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LogoAndVersionSection extends StatelessWidget {
  final String urlWJC = 'https://srqrobotics.com/apps/wifi-joystick-app.html';
  final String urlFB = 'https://www.facebook.com/srqrobotics';
  final String urlLi = 'https://www.linkedin.com/company/srq-robotics';

  final bool darkMode;

  const LogoAndVersionSection({
    Key? key,
    required this.darkMode,
  }) : super(key: key);

  Future<void> _copyToClipboard(String url) async {
    await Clipboard.setData(
      ClipboardData(
        text: url,
      ),
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $uri');
      }
    }
  }

  Future<void> _openEmail(
      {required String subject, required String msg}) async {
    String message = "App: WiFi Joystick Controller\n\n$msg\n";
    final uri =
        'mailto:apps@srqrobotics.com?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(message)}';

    if (await canLaunchUrl(Uri.parse(uri))) {
      if (!await launchUrl(Uri.parse(uri))) {
        throw Exception('Could not send email');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void _handleLinkOpening(int number) {
      if (number == 1) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "App Info",
                style: TextStyle(fontSize: 22),
              ),
              content: Text(
                "Open app info web page",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _copyToClipboard(urlWJC);
                  },
                  child: Text("Copy Link"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openLink(urlWJC);
                  },
                  child: const Text("Open Browser"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                )
              ],
            );
          },
        );
      } else if (number == 2) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "Facebook Page",
                style: TextStyle(fontSize: 22),
              ),
              content: Text(
                "View SRQ Robotics FB page",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _copyToClipboard(urlFB);
                  },
                  child: Text("Copy Link"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openLink(urlFB);
                  },
                  child: const Text("Open Browser"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                )
              ],
            );
          },
        );
      } else if (number == 3) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "LinkedIn Page",
                style: TextStyle(fontSize: 22),
              ),
              content: Text(
                "View SRQ Robotics LinkedIn page",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _copyToClipboard(urlLi);
                  },
                  child: Text("Copy Link"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openLink(urlLi);
                  },
                  child: const Text("Open Browser"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                )
              ],
            );
          },
        );
      } else if (number == 4) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController subjectController = TextEditingController();
            TextEditingController msgController = TextEditingController();
            return SingleChildScrollView(
              child: AlertDialog(
                title: const Text("We Like to Hear From You",
                    style: TextStyle(fontSize: 22)),
                content: RawScrollbar(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 450,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Subject",
                            style: TextStyle(fontSize: 16),
                          ),
                          TextField(
                            controller: subjectController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Message",
                            style: TextStyle(fontSize: 16),
                          ),
                          TextField(
                              controller: msgController,
                              maxLines: 8,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _openEmail(
                        subject: subjectController.text,
                        msg: msgController.text,
                      );
                    },
                    child: const Text("Send using Email App"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  )
                ],
              ),
            );
          },
        );
      }
    }

    return Container(
      width: 230,
      child: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image(
                    image: AssetImage('assets/app_icon/app_icon.png'),
                    height: 80.0,
                    width: 80.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  "WiFi Joystick Controller",
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "Version 1.0.0",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ],
          ),
          Expanded(
            child: SizedBox.expand(),
          ),
          Container(
            // color: Colors.brown,
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                Text(
                  "Reach us on",
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          _handleLinkOpening(1);
                        },
                        icon: Image(
                          image: AssetImage('assets/internet_icon.png'),
                          height: 45,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          _handleLinkOpening(2);
                        },
                        icon: Image(
                          image: AssetImage('assets/fb_icon.png'),
                          height: 45.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          _handleLinkOpening(3);
                        },
                        icon: Image(
                          image: AssetImage('assets/linkedin_icon.png'),
                          height: 45,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          _handleLinkOpening(4);
                        },
                        icon: Image(
                          image: AssetImage('assets/email_icon.png'),
                          height: 45,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppDetailsSection extends StatelessWidget {
  final String urlPS =
      'https://srqrobotics.com/apps/wifi-joystick-app/wifi-app-privacy-policy.html';
  final String urlTOS =
      'https://srqrobotics.com/apps/wifi-joystick-app/wifi-app-terms.html';
  final String urlArd =
      'https://github.com/srqrobotics/WiFi_Joystick_Controller_Arduino';
  final String urlPy =
      'https://github.com/srqrobotics/WiFi_Joystick_Controller_PythonSDK';
  final String urlSRQ = 'https://www.srqrobotics.com';

  final double width;

  /*
  To get the text container width
  screen start padding 10
  logo container 230
  divider 10
  this section start padding 12
  this section end padding 12
  screen end padding 10
  total 284

  width = screen width - btn bar width
  text container width = width - 284
*/

  const AppDetailsSection({
    Key? key,
    required this.width,
  }) : super(key: key);

  Future<void> _copyToClipboard(String url) async {
    await Clipboard.setData(
      ClipboardData(
        text: url,
      ),
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $uri');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void _handleLinkOpening(int number) {
      if (number == 1) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "Privacy Policy",
                style: TextStyle(fontSize: 22),
              ),
              content: Text(
                "View privacy policy of WiFi Joystick Controller",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _copyToClipboard(urlPS);
                  },
                  child: Text("Copy Link"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openLink(urlPS);
                  },
                  child: const Text("Open Browser"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                )
              ],
            );
          },
        );
      } else if (number == 2) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "Terms of Use",
                style: TextStyle(fontSize: 22),
              ),
              content: Text(
                "View terms of use of WiFi Joystick Controller",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _copyToClipboard(urlTOS);
                  },
                  child: Text("Copy Link"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openLink(urlTOS);
                  },
                  child: const Text("Open Browser"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                )
              ],
            );
          },
        );
      } else if (number == 3) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "Arduino Library",
                style: TextStyle(fontSize: 22),
              ),
              content: Text(
                "Download Arduino library from GitHub",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _copyToClipboard(urlArd);
                  },
                  child: Text("Copy Link"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openLink(urlArd);
                  },
                  child: const Text("Open Browser"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                )
              ],
            );
          },
        );
      } else if (number == 4) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "Python Library",
                style: TextStyle(fontSize: 22),
              ),
              content: Text(
                "Download Python library from GitHub",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _copyToClipboard(urlPy);
                  },
                  child: Text("Copy Link"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openLink(urlPy);
                  },
                  child: const Text("Open Browser"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                )
              ],
            );
          },
        );
      } else if (number == 5) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "Homepage",
                style: TextStyle(fontSize: 22),
              ),
              content: Text(
                "Open SRQ Robotics homepage",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _copyToClipboard(urlSRQ);
                  },
                  child: Text("Copy Link"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openLink(urlSRQ);
                  },
                  child: const Text("Open Browser"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                )
              ],
            );
          },
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 12.0,
        right: 12.0,
        left: 12.0,
      ),
      child: Column(
        children: [
          Expanded(
            child: RawScrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Container(
                  width: width - 284,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        textAlign: TextAlign.justify,
                        softWrap: true,
                        text: TextSpan(
                          text: "Introducing our ",
                          style: DefaultTextStyle.of(context).style.copyWith(
                                fontSize: 14.0,
                                fontFamily:
                                    (Platform.isIOS) ? '.SF UI Text' : 'Roboto',
                              ),
                          children: <TextSpan>[
                            TextSpan(
                                text: "WiFi Joystick Controller",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                recognizer: LongPressGestureRecognizer()
                                  ..onLongPress = () {
                                    Fluttertoast.showToast(
                                      msg: "Developed by Manodya Rasanjana",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 5,
                                    );
                                  }),
                            TextSpan(
                              text: ", designed for Arduino enthusiasts! "
                                  "Specializing in direct WiFi communication, "
                                  "our app bypasses online servers, offering faster "
                                  "response times and eliminating the need for an "
                                  "internet connection. Ideal for controlling your "
                                  "Arduino-based WiFi projects with ease and efficiency. "
                                  "Experience the difference in speed and reliability "
                                  "for all your hobbyist needs!\n",
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        textAlign: TextAlign.justify,
                        softWrap: true,
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style.copyWith(
                                fontSize: 15.0,
                              ),
                          text: "Please find ",
                          children: <TextSpan>[
                            TextSpan(
                              text: "privacy policy",
                              style: TextStyle(
                                color: Color(0xff3480EB),
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _handleLinkOpening(1);
                                },
                            ),
                            TextSpan(text: " and "),
                            TextSpan(
                              text: "terms of use",
                              style: TextStyle(
                                color: Color(0xff3480EB),
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _handleLinkOpening(2);
                                },
                            ),
                            TextSpan(text: " here.")
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 95,
            width: width - 284,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          "Download libraries",
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                _handleLinkOpening(3);
                              },
                              icon: Image(
                                image: AssetImage('assets/arduino_icon.png'),
                                height: 45,
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            IconButton(
                              onPressed: () {
                                _handleLinkOpening(4);
                              },
                              icon: Image(
                                image: AssetImage('assets/python_icon.png'),
                                height: 45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          children: [
                            Text(
                              "Copyright © 2023-2024 SRQ Robotics",
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _handleLinkOpening(5);
                              },
                              icon: Image(
                                image: AssetImage('assets/srq_icon.png'),
                                height: 45.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
