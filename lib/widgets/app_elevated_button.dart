import 'package:flutter/material.dart';

class AppElevatedButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  const AppElevatedButton(
      {required this.label, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            fixedSize: Size(double.maxFinite, 60),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white),
        onPressed: onPressed,
        child: Text(label));
  }
}
