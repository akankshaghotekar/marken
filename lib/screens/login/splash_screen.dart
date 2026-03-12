import 'package:flutter/material.dart';
import 'package:marken/screens/login/login_screen.dart';
import 'package:marken/utils/animation_helper/animated_page_route.dart';
import 'dart:async';

import 'package:marken/utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _zoomAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // optional navigation delay
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        AnimatedPageRoute(page: const LoginScreen()),
      );
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
      backgroundColor: AppColor.appBgColor,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _zoomAnimation,
            builder: (context, child) {
              return Transform.scale(scale: _zoomAnimation.value, child: child);
            },
            child: Image.asset(
              'assets/images/marken-logo.png',
              width: 600,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
