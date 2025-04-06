import 'dart:async';
import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qibla_finder/screens/widgets/loading_indicator.dart';
import 'package:qibla_finder/screens/widgets/location_error.dart';

class QiblahCompass extends StatefulWidget {
  const QiblahCompass({super.key});

  @override
  _QiblahCompassState createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  Stream<LocationStatus> get stream => _locationStreamController.stream;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: stream,
        builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const LoadingIndicator();
          if (snapshot.data!.enabled == true) {
            switch (snapshot.data!.status) {
              case LocationPermission.always:
              case LocationPermission.whileInUse:
                return QiblahCompassWidget();

              case LocationPermission.denied:
                return LocationErrorWidget(
                  error: "Location service permission denied",
                  callback: _checkLocationStatus,
                );
              case LocationPermission.deniedForever:
                return LocationErrorWidget(
                  error: "Location service Denied Forever !",
                  callback: _checkLocationStatus,
                );
              default:
                return const SizedBox();
            }
          } else {
            return LocationErrorWidget(
              error: "Please enable Location service",
              callback: _checkLocationStatus,
            );
          }
        },
      ),
    );
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else
      _locationStreamController.sink.add(locationStatus);
  }
}

class QiblahCompassWidget extends StatelessWidget {
  final _compassSvg = SvgPicture.asset('assets/compass.svg');
  final _needleSvg = SvgPicture.asset(
    'assets/needle.svg',
    fit: BoxFit.contain,
    alignment: Alignment.center,
  );

  QiblahCompassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen size for responsiveness
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Calculate size for images relative to the screen width
    final compassSize = screenWidth * 0.8; // 50% of the screen width
    final needleSize = screenWidth * 0.5; // 30% of the screen width

    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const LoadingIndicator();

        final qiblahDirection = snapshot.data!;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.22),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // Rotate and resize the compass image
                  Transform.rotate(
                    angle: (qiblahDirection.direction * (pi / 180) * -1),
                    child: SizedBox(
                      width: compassSize,
                      height: compassSize,
                      child: _compassSvg,
                    ),
                  ),
                  // Rotate and resize the needle image
                  Transform.rotate(
                    angle: (qiblahDirection.qiblah * (pi / 180) * -1),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: needleSize,
                      height: needleSize,
                      child: _needleSvg,
                    ),
                  ),
                  // Text displaying the offset value of Qiblah direction
                  // Positioned(
                  //   bottom: screenHeight *
                  //       0.8, // Dynamic positioning based on screen height
                  //   child: Text(
                  //     "${qiblahDirection.offset.toStringAsFixed(3)}°",
                  //     style: const TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 15,
                  //     ),
                  //   ),
                  // ),
                  // Label "Find Qiblah"
                  //  const Positioned(
                  //   bottom: 2, // Dynamic positioning based on screen height
                  //   child: Text(
                  //     "Find Qiblah",
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 15,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.05,
              ), // Adds space above the text
              child: Text(
                "${qiblahDirection.offset.toStringAsFixed(3)}°",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            // Label "Find Qiblah" (below the offset text)
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.02,
              ), // Adds space above the next text
              child: const Text(
                "Find Qiblah",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        );
      },
    );
  }
}
