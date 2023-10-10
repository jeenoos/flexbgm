import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button(
      {super.key, required this.text, required this.onPressed, this.margin});

  final String text; //출력 텍스트
  final VoidCallback onPressed; //onPressed 이벤트 핸들러
  final EdgeInsets? margin; //버튼의 마진

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: margin,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
        ),
        child: Text(
          style: const TextStyle(
            fontSize: 16,
          ),
          text,
        ),
      ),
    );
  }
}
