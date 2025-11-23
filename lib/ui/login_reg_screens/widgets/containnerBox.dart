import 'package:flutter/material.dart';

class containnerBox extends StatelessWidget {
  const containnerBox({
    super.key,
    required this.bgColors,
    required this.text,
    this.prefixIcons,
    required this.textColors,
    this.onTap,
  });

  final Color bgColors;
  final String text;
  final String? prefixIcons;
  final Color textColors;
  final onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColors,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Row(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcons != null) ...[
                Image.asset(prefixIcons!, height: 24, width: 24),
                SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: textColors,
                  fontSize: 16,

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

