import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(
          size: 20,
          color: Colors.redAccent,
          FontAwesomeIcons.music,
        ),
        SizedBox(width: 4),
        Text(
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          'FLEX BGM',
        ),
      ],
    );
  }
}
