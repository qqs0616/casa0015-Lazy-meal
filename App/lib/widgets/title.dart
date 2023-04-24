import 'package:flutter/material.dart';

///Title (with bin icon)
class TitleWidget extends StatelessWidget {
  final String title;
  final Function()? onPress;
  final bool hasButton;
  final double fontSize;

  const TitleWidget(
      {Key? key,
      required this.title,
      this.onPress,
      this.hasButton = true,
      this.fontSize = 50})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        hasButton
            ? IconButton(
                onPressed: onPress,
                icon: const Icon(
                  Icons.delete_forever_outlined,
                  size: 40,
                ),
                tooltip: "delete all",
              )
            : const SizedBox.shrink()
      ],
    );
  }
}
