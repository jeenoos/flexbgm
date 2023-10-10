import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  const TextInput(
      {super.key,
      this.maxLines,
      this.enabled,
      this.onChanged,
      this.onTap,
      this.errorText,
      this.labelText,
      this.hintText,
      this.width,
      this.height,
      required this.controller});

  final int? maxLines; //최대 라인 수
  final String? hintText; //힌트 텍스트
  final String? errorText;
  final String? labelText;
  final num? width;
  final num? height;
  final TextEditingController controller; //컨트롤러
  final bool? enabled;
  final Function(String)? onChanged;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width?.toDouble() ?? double.infinity,
      height: height?.toDouble() ?? double.infinity,
      child: TextFormField(
        enabled: enabled ?? true,
        controller: controller,
        expands: true,
        minLines: null,
        maxLines: null,
        onChanged: onChanged,
        onTap: onTap,
        cursorColor: Colors.grey,
        decoration: InputDecoration(
          labelText: labelText,
          errorText: errorText,
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          errorStyle: const TextStyle(height: 0.0),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          // enabledBorder: const OutlineInputBorder(
          //   borderSide: BorderSide(
          //     color: Colors.grey,
          //   ),
          // ),
          // focusedBorder: const OutlineInputBorder(
          //   borderSide: BorderSide(
          //     color: Colors.grey,
          //   ),
          // ),
          // errorBorder: const OutlineInputBorder(
          //   borderSide: BorderSide(
          //     color: Colors.grey,
          //   ),
          // ),
          // focusColor: Colors.grey,
        ),
      ),
    );
  }
}
