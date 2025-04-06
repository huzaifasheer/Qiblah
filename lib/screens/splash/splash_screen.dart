import 'package:flutter/material.dart';
import 'package:qibla_finder/screens/Qiblah/qiblah_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
   @override
  void initState() {
    super.initState();

    // Wait for 5 seconds and navigate to HomeScreen
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QiblahScreen()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset("assets/splash.png",
             width: 200,
             height: 200,
            ),
          ),
          SizedBox(height: 10),
           Text(
                "Muslim Qiblah Finder App",
                style: TextStyle( 
                  fontWeight: FontWeight.bold,
                 fontSize: 15,
                 ),
              ),
        ],
      ),
    );
  }
}