
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:qibla_finder/screens/widgets/loading_indicator.dart';
import 'package:qibla_finder/screens/widgets/qiblah_compass.dart';

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen> {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _deviceSupport,
        builder: (_, AsyncSnapshot<bool?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error.toString()}"));
          }

          if (snapshot.data!) {
            return const QiblahCompass(); // Show Qiblah Compass if sensor is supported
          } else {
            return const Center(
              child: Text(
                "Device does not support Qiblah sensor.",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ); // Show message if sensor is not supported
          }
        },
      ),
    );
  }
}
