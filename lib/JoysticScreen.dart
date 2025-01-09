import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class JoysticScreen extends StatefulWidget {
  const JoysticScreen({super.key});

  @override
  State<JoysticScreen> createState() => _JoysticScreenState();
}

class _JoysticScreenState extends State<JoysticScreen> {
  bool A1_R_tap = false;
  bool A2_R_tap = false;
  bool A3_R_tap = false;
  bool A4_R_tap = false;
  bool A1_B_tap = false;
  bool A2_B_tap = false;
  bool A3_B_tap = false;
  bool A4_B_tap = false;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        title: Text(
          "ESP WIFI REMOTE",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ))
        ],
      ),
      body: Container(
        width: width,
        height: height,
        color: Color(0xFF36393B),
        child: Stack(
          children: [
            Positioned.fill(
                child: Image(
              image: AssetImage("assets/joysticBackground.jpg"),
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.68),
            )),
            SizedBox(
              width: width,
              height: height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SafeArea(
                    child: Joystick(
                      listener: (details) {},
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
                  ),
                  SafeArea(
                    child: Joystick(
                      listener: (details) {},
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
                  ),
                ],
              ),
            ),
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
            Positioned(
              top: height * 0.42,
              child: SizedBox(
                width: width,
                height: height * 0.3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: width * 0.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                print("tapped");
                                setState(() {
                                  A1_R_tap = !A1_R_tap;
                                });
                              },
                              child: Container(
                                width: width * 0.05,
                                height: width * 0.05,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.greenAccent),
                                child: Stack(
                                  children: [
                                    Image(
                                      image: A1_R_tap == false
                                          ? AssetImage("assets/roundButton.png")
                                          : AssetImage(
                                              "assets/clicked_round.png"),
                                    ),
                                    Center(
                                      child: Text(
                                        "A1",
                                        style: TextStyle(
                                            color: A1_R_tap == false
                                                ? Color(0xFF1FBFFF)
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print("tapped");
                                setState(() {
                                  A2_R_tap = !A2_R_tap;
                                });
                              },
                              child: Container(
                                width: width * 0.05,
                                height: width * 0.05,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.greenAccent),
                                child: Stack(
                                  children: [
                                    Image(
                                      image: A2_R_tap == false
                                          ? AssetImage("assets/roundButton.png")
                                          : AssetImage(
                                              "assets/clicked_round.png"),
                                    ),
                                    Center(
                                      child: Text(
                                        "A2",
                                        style: TextStyle(
                                            color: A2_R_tap == false
                                                ? Color(0xFF1FBFFF)
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print("tapped");
                                setState(() {
                                  A3_R_tap = !A3_R_tap;
                                });
                              },
                              child: Container(
                                width: width * 0.05,
                                height: width * 0.05,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.greenAccent),
                                child: Stack(
                                  children: [
                                    Image(
                                      image: A3_R_tap == false
                                          ? AssetImage("assets/roundButton.png")
                                          : AssetImage(
                                              "assets/clicked_round.png"),
                                    ),
                                    Center(
                                      child: Text(
                                        "A3",
                                        style: TextStyle(
                                            color: A3_R_tap == false
                                                ? Color(0xFF1FBFFF)
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print("tapped");
                                setState(() {
                                  A4_R_tap = !A4_R_tap;
                                });
                              },
                              child: Container(
                                width: width * 0.05,
                                height: width * 0.05,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.greenAccent),
                                child: Stack(
                                  children: [
                                    Image(
                                      image: A4_R_tap == false
                                          ? AssetImage("assets/roundButton.png")
                                          : AssetImage(
                                              "assets/clicked_round.png"),
                                    ),
                                    Center(
                                      child: Text(
                                        "A4",
                                        style: TextStyle(
                                            color: A4_R_tap == false
                                                ? Color(0xFF1FBFFF)
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width * 0.28,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  A1_B_tap = !A1_B_tap;
                                  A2_B_tap = false;
                                  A3_B_tap = false;
                                  A4_B_tap = false;
                                });
                              },
                              child: SizedBox(
                                width: width * 0.07,
                                height: height * 0.06,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image(
                                      image: A1_B_tap == false
                                          ? AssetImage(
                                          "assets/RectangleButton.png")
                                          : AssetImage(
                                          "assets/clicked_box.png"),
                                      fit: BoxFit.cover,
                                      width: width *
                                          0.07, // Use cover to make the image fill the container
                                    ),
                                    Text(
                                      "A1",
                                      style: TextStyle(
                                          color: A1_B_tap == false?
                                          Color(0xFF1FBFFF):Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  A2_B_tap = !A2_B_tap;
                                  A1_B_tap = false;
                                  A3_B_tap = false;
                                  A4_B_tap = false;
                                });
                              },
                              child: SizedBox(
                                width: width * 0.07,
                                height: height * 0.06,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image(
                                      image: A2_B_tap == false
                                          ? AssetImage(
                                          "assets/RectangleButton.png")
                                          : AssetImage(
                                          "assets/clicked_box.png"),
                                      fit: BoxFit.cover,
                                      width: width *
                                          0.07, // Use cover to make the image fill the container
                                    ),
                                    Text(
                                      "A2",
                                      style: TextStyle(
                                          color: A2_B_tap == false?
                                          Color(0xFF1FBFFF):Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  setState(() {
                                    A3_B_tap = !A3_B_tap;
                                    A2_B_tap = false;
                                    A1_B_tap = false;
                                    A4_B_tap = false;
                                  });
                                });
                              },
                              child: SizedBox(
                                width: width * 0.07,
                                height: height * 0.06,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image(
                                      image: A3_B_tap == false
                                          ? AssetImage(
                                          "assets/RectangleButton.png")
                                          : AssetImage(
                                          "assets/clicked_box.png"),
                                      fit: BoxFit.cover,
                                      width: width *
                                          0.07, // Use cover to make the image fill the container
                                    ),
                                    Text(
                                      "A3",
                                      style: TextStyle(
                                          color: A3_B_tap == false?
                                          Color(0xFF1FBFFF):Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {

                                  setState(() {
                                    A4_B_tap = !A4_B_tap;
                                    A2_B_tap = false;
                                    A3_B_tap = false;
                                    A1_B_tap = false;
                                  });

                              },
                              child: SizedBox(
                                width: width * 0.07,
                                height: height * 0.06,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image(
                                      image: A4_B_tap == false
                                          ? AssetImage(
                                              "assets/RectangleButton.png")
                                          : AssetImage(
                                          "assets/clicked_box.png"),
                                      fit: BoxFit.cover,
                                      width: width *
                                          0.07, // Use cover to make the image fill the container
                                    ),
                                    Text(
                                      "A4",
                                      style: TextStyle(
                                          color: A4_B_tap == false?
                                          Color(0xFF1FBFFF):Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                left: width * 0.1,
                child: Container(
                  width: width * 0.05,
                  height: height * 0.06,
                  color: Colors.white,
                  child: Image(
                    image: AssetImage("assets/RectangleButton.png"),
                    fit: BoxFit.fitWidth,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
