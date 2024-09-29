import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:funko_vault/screens/bottom_nav.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "iFunko",
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoaded = false; 
  late AnimationController _controller; 
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);

    // Start loading sequence
    nextScreen();
  }

  void nextScreen() {
    Timer(const Duration(seconds: 2), () {
      _controller.forward().then((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNav()),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Lottie.network(
                  "https://lottie.host/f290cff8-6dc7-46ba-8943-11669201ce2d/AeqhJBUft4.json",
                  onLoaded: (p0) {
                    setState(() {
                      _isLoaded = true; 
                    });
                  },
                ),
              ).animate().fadeIn(duration: 2.seconds),
              // Show text only when Lottie is loaded
              if (_isLoaded) ...[
                Text(
                  "Welcome to iFunko",
                  style: GoogleFonts.fredoka(
                    fontSize: 36,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 2.seconds),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
