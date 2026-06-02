import 'package:flutter/material.dart';

class NetworkInfoBar extends StatelessWidget {
  const NetworkInfoBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red, width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 4),
      child: const Text("No Internet Connection", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
