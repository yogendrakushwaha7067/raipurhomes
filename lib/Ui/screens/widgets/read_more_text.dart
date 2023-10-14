import '../../../utils/ui_utils.dart';
import 'package:flutter/material.dart';

class ReadMoreText extends StatefulWidget {
  final String text;
  final int? maxVisibleCharectors;
  final TextStyle? style;
  final TextStyle? readMoreButtonStyle;
  const ReadMoreText(
      {super.key,
      required this.text,
      this.maxVisibleCharectors,
      this.style,
      this.readMoreButtonStyle});

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool showingFullText = false;

  buildReadMore(String text) {
    int textLength = text.length;

    if (textLength > (widget.maxVisibleCharectors?.toInt() ?? 100)) {
      return Wrap(
        children: [
          Text(
            "${text.substring(0, showingFullText == false ? (widget.maxVisibleCharectors ?? 100) : textLength)}...",
            style: widget.style,
          ),
          TextButton(
              style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(EdgeInsets.zero)),
              onPressed: () {
                showingFullText = !showingFullText;
                setState(() {});
              },
              child: Text(
                showingFullText == false
                    ? UiUtils.getTranslatedLabel(context, "readMoreLbl")
                    : UiUtils.getTranslatedLabel(context, "readLessLbl"),
                style: widget.readMoreButtonStyle,
              ))
        ],
      );
    }

    return Text(text);
  }

  @override
  Widget build(BuildContext context) {
    return buildReadMore(widget.text);
  }
}
