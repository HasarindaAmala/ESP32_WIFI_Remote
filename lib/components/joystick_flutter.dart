/*
* Author      : Manodya Rasanjana <manodya97dev@gmail.com>
* Company     : SRQ Robotics, Sri Lanka (https://www.srqrobotics.com/)
* Website     : https://github.com/ManodyaRasanjana
* Version     : 0.1.0
* Date        : October 30, 2023
* Description : A highly customizable joystick widget for flutter
*/

import 'package:flutter/material.dart';
import 'dart:math';

typedef SRQJoystickCallBack = void Function(
    double degrees,
    double distance,
    double xOffset,
    double yOffset,
    );

class SRQJoystick extends StatefulWidget {
  final double baseSize; // size of the base i.e. total widget size
  final double stickSize; // size of the middle stick
  final SRQJoystickCallBack onDirectionChanged; // data providing function
  final Duration? interval; // interval between two data callbacks. default 0
  final bool limitedTouch; // user must touch top of the stick to move it
  final bool stayPut; // stick will stay as it left. Double click to reset
  final Widget? base; // custom stateless widget for joystick base
  final Widget? stick; // custom stateless widget for joystick stick
  final bool darkMode;
  final bool keepSameSize; // to maintain initial widget size in every builds

  const SRQJoystick({
    Key? key,
    required this.baseSize,
    required this.stickSize,
    required this.onDirectionChanged,
    this.interval,
    this.limitedTouch = true,
    this.stayPut = false,
    this.base,
    this.stick,
    this.darkMode = false,
    this.keepSameSize = false,
  }) : super(key: key);

  @override
  State<SRQJoystick> createState() => _SRQJoystickState();
}

class _SRQJoystickState extends State<SRQJoystick> {
  bool _touchedOnStick = false; // touch verify flag if limitedTouch is enabled

  double _xLast = 0.0; // last position of stick, if stayPut is enabled
  double _yLast = 0.0;

  double? _baseSize;
  double? _stickSize;

  Offset? lastPosition; // where touch or drag is happened
  Offset? stickPosition; // where to place the stick
  DateTime? callbackTimestamp_; // to maintain interval

  void _calculateItemSize() {
    if (widget.keepSameSize) {
      _baseSize ??= widget.baseSize;
      _stickSize ??= (widget.stickSize >= widget.baseSize)
          ? widget.baseSize / 2
          : widget.stickSize;
    } else {
      _baseSize = widget.baseSize;
      _stickSize = (widget.stickSize >= widget.baseSize)
          ? widget.baseSize / 2
          : widget.stickSize;
    }
  }

  void _calculateInitPosition() {
    lastPosition ??= Offset(_baseSize! / 2, _baseSize! / 2);
    stickPosition ??= calculateStickPosition(
      lastPosition: lastPosition!,
      offset: const Offset(0, 0),
      baseSize: _baseSize!,
      stickSize: _stickSize!,
    );
  }

  @override
  Widget build(BuildContext context) {
    _calculateItemSize();
    _calculateInitPosition();
    callbackTimestamp_ ??= DateTime.now();

    return StatefulBuilder(
      builder: (context, setState) {
        Widget joystick = Stack(
          children: [
            widget.base ??
                _SRQJoystickBase(
                  baseSize: _baseSize!,
                  stickSize: _stickSize!,
                  darkMode: widget.darkMode,
                ),
            Positioned(
              top: stickPosition?.dy,
              left: stickPosition?.dx,
              child: widget.stick ??
                  _SRQJoystickStick(
                    stickSize: _stickSize!,
                    darkMode: widget.darkMode,
                  ),
            ),
          ],
        );

        return GestureDetector(
          child: joystick,
          // use to reset stick to the origin point when stayPut is enabled
          onDoubleTap: () {
            if (widget.stayPut) {
              widget.onDirectionChanged(0.0, 0.0, 0.0, 0.0);
              stickPosition = calculateStickPosition(
                lastPosition: Offset(_baseSize! / 2, _baseSize! / 2),
                offset: const Offset(0, 0),
                baseSize: _baseSize!,
                stickSize: _stickSize!,
              );
              _xLast = 0.0;
              _yLast = 0.0;
              setState(() => lastPosition = Offset(_stickSize!, _stickSize!));
            }
          },
          onPanStart: (details) {
            callbackTimestamp_ ??= DateTime.now();
            validateGesture(
              baseSize: _baseSize!,
              stickSize: _stickSize!,
              offset: details.localPosition,
            );
            setState(() => lastPosition = details.localPosition);
          },
          onPanUpdate: (details) {
            if ((widget.limitedTouch && _touchedOnStick) ||
                !widget.limitedTouch) {
              callbackTimestamp_ = processGesture(
                baseSize: _baseSize!,
                stickSize: _stickSize!,
                offset: details.localPosition,
                callbackTimestamp: callbackTimestamp_!,
              );
              stickPosition = calculateStickPosition(
                lastPosition: lastPosition!,
                offset: details.localPosition,
                baseSize: _baseSize!,
                stickSize: _stickSize!,
              );
              setState(() => lastPosition = details.localPosition);
            }
          },
          onPanEnd: (details) {
            callbackTimestamp_ = null;
            _touchedOnStick = false;
            if (!widget.stayPut) {
              widget.onDirectionChanged(0.0, 0.0, 0.0, 0.0);
              stickPosition = calculateStickPosition(
                lastPosition: Offset(_baseSize! / 2, _baseSize! / 2),
                offset: const Offset(0, 0),
                baseSize: _baseSize!,
                stickSize: _stickSize!,
              );
              setState(() => lastPosition = Offset(_stickSize!, _stickSize!));
            }
          },
        );
      },
    );
  }

  Offset calculateStickPosition({
    required Offset lastPosition,
    required Offset offset,
    required double baseSize,
    required double stickSize,
  }) {
    double middle = baseSize / 2.0;

    double angle = atan2(offset.dy - middle, offset.dx - middle);
    double degrees = angle * 180 / pi;
    if (offset.dx < middle && offset.dy < middle) {
      degrees = 360 + degrees;
    }
    bool isStartPosition =
        lastPosition.dx == stickSize && lastPosition.dy == stickSize;
    double lastAngleRadians = (isStartPosition) ? 0 : (degrees) * (pi / 180.0);

    var baseRadius = baseSize / 2;
    var stickRadius = stickSize / 2;

    var x = (lastAngleRadians == -1)
        ? baseRadius - stickRadius
        : (baseRadius - stickRadius) +
        (baseRadius - stickRadius) * cos(lastAngleRadians);
    var y = (lastAngleRadians == -1)
        ? baseRadius - stickRadius
        : (baseRadius - stickRadius) +
        (baseRadius - stickRadius) * sin(lastAngleRadians);

    var xPosition = lastPosition.dx - stickRadius;
    var yPosition = lastPosition.dy - stickRadius;

    var angleRadianPlus = lastAngleRadians + pi / 2;
    if (angleRadianPlus < pi / 2) {
      if (xPosition > x) {
        xPosition = x;
      }
      if (yPosition < y) {
        yPosition = y;
      }
    } else if (angleRadianPlus < pi) {
      if (xPosition > x) {
        xPosition = x;
      }
      if (yPosition > y) {
        yPosition = y;
      }
    } else if (angleRadianPlus < 3 * pi / 2) {
      if (xPosition < x) {
        xPosition = x;
      }
      if (yPosition > y) {
        yPosition = y;
      }
    } else {
      if (xPosition < x) {
        xPosition = x;
      }
      if (yPosition < y) {
        yPosition = y;
      }
    }

    return Offset(xPosition, yPosition);
  }

  // return true if user touch on the stick. Can use to validate when limitedTouch is enabled
  bool validateGesture({
    required double baseSize,
    required double stickSize,
    required Offset offset,
  }) {
    double dx = max(0, min(offset.dx, baseSize));
    double dy = max(0, min(offset.dy, baseSize));

    double middle = baseSize / 2.0;
    double distance = sqrt(pow(middle - dx, 2) + pow(middle - dy, 2));

    if (widget.stayPut) {
      double angleRad = atan2(offset.dy - middle, offset.dx - middle);
      double mappedDistance = mapValues(
          value: distance,
          fromLow: 0,
          fromHigh: (baseSize - stickSize) / 2,
          toLow: 0,
          toHigh: baseSize / 2);
      double normalizedDistance = min(mappedDistance / (baseSize / 2), 1.0);

      double xOffset = (normalizedDistance * cos(angleRad)) * 100;
      double yOffset = (normalizedDistance * sin(angleRad)) * -100;

      double xDiff = (xOffset - _xLast).abs();
      double yDiff = (yOffset - _yLast).abs();

      _touchedOnStick =
      (xDiff < stickSize / 2 && yDiff < stickSize / 2) ? true : false;
    } else {
      _touchedOnStick = (distance < stickSize / 2) ? true : false;
    }
    return _touchedOnStick;
  }

  DateTime processGesture({
    required double baseSize,
    required double stickSize,
    required Offset offset,
    required DateTime callbackTimestamp,
  }) {
    double dx = max(0, min(offset.dx, baseSize));
    double dy = max(0, min(offset.dy, baseSize));

    double middle = baseSize / 2.0;

    // distance to the edge of the base
    double distance = sqrt(pow(middle - dx, 2) + pow(middle - dy, 2));
    // mapping values to middle of the stick. This way, distance if based on stick middle point, not the edge of the base
    double mappedDistance = mapValues(
        value: distance,
        fromLow: 0,
        fromHigh: (baseSize - stickSize) / 2,
        toLow: 0,
        toHigh: baseSize / 2);
    // normalizing distance value between 0 and 1
    double normalizedDistance = min(mappedDistance / (baseSize / 2), 1.0);

    double angleRad = atan2(offset.dy - middle, offset.dx - middle);
    double angleDeg = (angleRad * 180 / pi) + 90;
    (offset.dx < middle && offset.dy < middle) ? angleDeg += 360 : angleDeg;

    double xOffset = (normalizedDistance * cos(angleRad)) * 100;
    double yOffset = (normalizedDistance * sin(angleRad)) * -100;

    if (widget.stayPut) {
      _xLast = xOffset;
      _yLast = yOffset;
    }

    if (canCallOnDirectionChanged(callbackTimestamp)) {
      widget.onDirectionChanged(angleDeg, normalizedDistance, xOffset, yOffset);
      return DateTime.now();
    } else {
      return callbackTimestamp;
    }
  }

  // same as Arduino Map() function
  double mapValues(
      {required double value,
        required double fromLow,
        required double fromHigh,
        required double toLow,
        required double toHigh}) {
    return (value - fromLow) * (toHigh - toLow) / (fromHigh - fromLow) + toLow;
  }

  // check for interval
  bool canCallOnDirectionChanged(DateTime callbackTimestamp) {
    if (widget.interval != null) {
      int intervalMillis = widget.interval!.inMilliseconds;
      int timestampMillis = callbackTimestamp.millisecondsSinceEpoch;
      int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;

      if (currentTimeMillis - timestampMillis <= intervalMillis) {
        return false;
      }
    }
    return true;
  }
}

// widget for joystick base
class _SRQJoystickBase extends StatelessWidget {
  final double baseSize;
  final double stickSize;
  final bool darkMode;

  const _SRQJoystickBase({
    Key? key,
    required this.baseSize,
    required this.stickSize,
    required this.darkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: baseSize,
      height: baseSize,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: darkMode
            ? _SRQJoystickBaseDarkModePainter(
            baseSize: baseSize, stickSize: stickSize)
            : _SRQJoystickBaseLightModePainter(
            baseSize: baseSize, stickSize: stickSize),
      ),
    );
  }
}

class _SRQJoystickBaseLightModePainter extends CustomPainter {
  double baseSize;
  double stickSize;

  _SRQJoystickBaseLightModePainter({
    required this.baseSize,
    required this.stickSize,
  });

  final _baseFillPaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.fill;
  final _borderPaint = Paint()
    ..color = const Color(0xFF6E6E6E)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;
  final _centerPaint = Paint()
    ..color = const Color(0xFFC3C3C3)
    ..style = PaintingStyle.fill;
  final _stickPositionPaint = Paint()
    ..color = const Color(0xFF828282)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;
  final _linePaint = Paint()
    ..color = const Color(0xFF828282)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    canvas.drawCircle(center, radius, _baseFillPaint);
    canvas.drawCircle(center, radius - 2, _borderPaint);
    canvas.drawCircle(center, radius - 10, _centerPaint);
    canvas.drawCircle(center, (stickSize / 2) - 2, _stickPositionPaint);

    canvas.drawLine(Offset(radius - 1, radius * 0.15),
        Offset(radius * 1.15, radius * 0.3), _linePaint);
    canvas.drawLine(Offset(radius + 1, radius * 0.15),
        Offset(radius - radius * 0.15, radius * 0.3), _linePaint);

    canvas.drawLine(Offset(radius - 1, radius * 1.85),
        Offset(radius * 1.15, radius * 1.7), _linePaint);
    canvas.drawLine(Offset(radius + 1, radius * 1.85),
        Offset(radius - radius * 0.15, radius * 1.7), _linePaint);

    canvas.drawLine(Offset(radius * 0.15, radius - 1),
        Offset(radius * 0.3, radius * 1.15), _linePaint);
    canvas.drawLine(Offset(radius * 0.15, radius + 1),
        Offset(radius * 0.3, radius - radius * 0.15), _linePaint);

    canvas.drawLine(Offset(radius * 1.85, radius - 1),
        Offset(radius * 1.7, radius * 1.15), _linePaint);
    canvas.drawLine(Offset(radius * 1.85, radius + 1),
        Offset(radius * 1.7, radius - radius * 0.15), _linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _SRQJoystickBaseDarkModePainter extends CustomPainter {
  double baseSize;
  double stickSize;

  _SRQJoystickBaseDarkModePainter({
    required this.baseSize,
    required this.stickSize,
  });

  final _baseFillPaint = Paint()
    ..color = const Color(0xFF999999)
    ..style = PaintingStyle.fill;
  final _borderPaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;
  final _centerPaint = Paint()
    ..color = const Color(0xFFD9D9D9)
    ..style = PaintingStyle.fill;
  final _stickPositionPaint = Paint()
    ..color = const Color(0xFF828282)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;
  final _linePaint = Paint()
    ..color = const Color(0xFF828282)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    canvas.drawCircle(center, radius, _baseFillPaint);
    canvas.drawCircle(center, radius - 2, _borderPaint);
    canvas.drawCircle(center, radius - 10, _centerPaint);
    canvas.drawCircle(center, (stickSize / 2) - 2, _stickPositionPaint);

    canvas.drawLine(Offset(radius - 1, radius * 0.15),
        Offset(radius * 1.15, radius * 0.3), _linePaint);
    canvas.drawLine(Offset(radius + 1, radius * 0.15),
        Offset(radius - radius * 0.15, radius * 0.3), _linePaint);

    canvas.drawLine(Offset(radius - 1, radius * 1.85),
        Offset(radius * 1.15, radius * 1.7), _linePaint);
    canvas.drawLine(Offset(radius + 1, radius * 1.85),
        Offset(radius - radius * 0.15, radius * 1.7), _linePaint);

    canvas.drawLine(Offset(radius * 0.15, radius - 1),
        Offset(radius * 0.3, radius * 1.15), _linePaint);
    canvas.drawLine(Offset(radius * 0.15, radius + 1),
        Offset(radius * 0.3, radius - radius * 0.15), _linePaint);

    canvas.drawLine(Offset(radius * 1.85, radius - 1),
        Offset(radius * 1.7, radius * 1.15), _linePaint);
    canvas.drawLine(Offset(radius * 1.85, radius + 1),
        Offset(radius * 1.7, radius - radius * 0.15), _linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// widget for joystick stick
class _SRQJoystickStick extends StatelessWidget {
  final double stickSize;
  final bool darkMode;

  const _SRQJoystickStick({
    Key? key,
    required this.stickSize,
    required this.darkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: stickSize,
      height: stickSize,
      decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black26,
            width: 1.0,
            style: BorderStyle.solid,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              spreadRadius: 4,
              blurRadius: 8,
              offset: Offset(0, 3),
            )
          ]),
      child: CustomPaint(
          painter: darkMode
              ? _SRQJoystickStickDarkModePainter(
            stickSize: stickSize,
          )
              : _SRQJoystickStickLightModePainter(
            stickSize: stickSize,
          )),
    );
  }
}

class _SRQJoystickStickLightModePainter extends CustomPainter {
  double stickSize;

  _SRQJoystickStickLightModePainter({
    required this.stickSize,
  });

  final _fillCirclePaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.fill;

  final _middleCirclePaint = Paint()
    ..color = const Color(0x73000000)
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  final _lCirclesPaint = Paint()
    ..color = const Color(0x73000000)
    ..strokeWidth = 0.8
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final tlCircleCenter = Offset(radius, radius * 0.25);
    final blCircleCenter = Offset(radius, radius * 1.75);
    final llCircleCenter = Offset(radius * 0.25, radius);
    final rlCircleCenter = Offset(radius * 1.75, radius);

    canvas.drawCircle(center, radius, _fillCirclePaint);
    canvas.drawCircle(center, radius * 0.5, _middleCirclePaint);
    canvas.drawCircle(tlCircleCenter, radius * 0.08, _lCirclesPaint);
    canvas.drawCircle(blCircleCenter, radius * 0.08, _lCirclesPaint);
    canvas.drawCircle(llCircleCenter, radius * 0.08, _lCirclesPaint);
    canvas.drawCircle(rlCircleCenter, radius * 0.08, _lCirclesPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _SRQJoystickStickDarkModePainter extends CustomPainter {
  double stickSize;

  _SRQJoystickStickDarkModePainter({
    required this.stickSize,
  });

  final _fillCirclePaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.fill;

  final _middleCirclePaint = Paint()
    ..color = const Color(0x73000000)
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  final _lCirclesPaint = Paint()
    ..color = const Color(0x73000000)
    ..strokeWidth = 0.8
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final tlCircleCenter = Offset(radius, radius * 0.25);
    final blCircleCenter = Offset(radius, radius * 1.75);
    final llCircleCenter = Offset(radius * 0.25, radius);
    final rlCircleCenter = Offset(radius * 1.75, radius);

    canvas.drawCircle(center, radius, _fillCirclePaint);
    canvas.drawCircle(center, radius * 0.5, _middleCirclePaint);
    canvas.drawCircle(tlCircleCenter, radius * 0.08, _lCirclesPaint);
    canvas.drawCircle(blCircleCenter, radius * 0.08, _lCirclesPaint);
    canvas.drawCircle(llCircleCenter, radius * 0.08, _lCirclesPaint);
    canvas.drawCircle(rlCircleCenter, radius * 0.08, _lCirclesPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
