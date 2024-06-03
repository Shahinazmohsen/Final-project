import 'package:flutter/material.dart';

class GridViewItem extends StatelessWidget {
  final String label;
  final Color color;
  final IconData iconData;
  final void Function()? onTap;

  const GridViewItem(
      {required this.label,
      required this.color,
      required this.iconData,
      required this.onTap,
      super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        surfaceTintColor: Colors.white,
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: color.withOpacity(.3),
                child: Icon(
                  iconData,
                  color: color,
                  size: 40,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
