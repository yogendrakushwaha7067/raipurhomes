import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SomethingWentWrong extends StatelessWidget {
  const SomethingWentWrong({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset("assets/lottie/cat.json"),
    );
  }
}
