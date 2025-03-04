import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'Authentication.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToRegister();
  }

  _navigateToRegister() async {
    await Future.delayed(const Duration(seconds: 7));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Authentication()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple, Colors.blueAccent],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Image
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20), // Space between logo and text

              // Animated Text with Poppins Font
              AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'Task Master',
                    textStyle: const TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins', // Using Poppins font
                    ),
                    colors: [
                      Colors.white,
                      Colors.blue,
                      Colors.yellow,
                      Colors.red,
                    ],
                    speed: const Duration(milliseconds: 400),
                  ),
                ],
                isRepeatingAnimation: true,
                totalRepeatCount: 3,
              ),

              const SizedBox(height: 10),

              // Subtitle with Poppins Font
              const Text(
                "Unlocking Your Dream Job, One Click at a Time!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 30),

              // Lottie Loading Animation
              SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset(
                  'assets/json/l.json',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}