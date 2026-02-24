import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int trimLines;

  const ExpandableText({
    required this.text,
    this.style,
    this.trimLines = 3,
    super.key,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text,
      style: widget.style,
      maxLines: isExpanded ? null : widget.trimLines,
      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget,
        GestureDetector(
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: Text(
            isExpanded ? 'Read less' : 'Read more',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}