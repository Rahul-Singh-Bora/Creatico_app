import 'package:flutter/material.dart';

class HeroTaglineWidget extends StatelessWidget {
  const HeroTaglineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: const Text(
        "Your next viral content idea… just a tap away.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
