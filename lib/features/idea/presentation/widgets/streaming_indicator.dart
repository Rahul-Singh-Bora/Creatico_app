// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class StreamingIndicator extends StatefulWidget {
  final bool isStreaming;
  final String text;

  const StreamingIndicator({
    super.key,
    required this.isStreaming,
    required this.text,
  });

  @override
  State<StreamingIndicator> createState() => _StreamingIndicatorState();
}

class _StreamingIndicatorState extends State<StreamingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isStreaming) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreamingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming && !oldWidget.isStreaming) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isStreaming && oldWidget.isStreaming) {
      _animationController.stop();
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styleSheet = MarkdownStyleSheet(
      p: const TextStyle(color: Colors.white, height: 1.5),
      listBullet: const TextStyle(color: Colors.white),
      h1: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      h3: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
    );

    if (!widget.isStreaming) {
      return MarkdownBody(
        data: widget.text,
        styleSheet: styleSheet,
        softLineBreak: true,
        shrinkWrap: true,
        extensionSet: md.ExtensionSet.gitHubWeb,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MarkdownBody(
                data: widget.text,
                styleSheet: styleSheet,
                softLineBreak: true,
                shrinkWrap: true,
                extensionSet: md.ExtensionSet.gitHubWeb,
              ),
            ),
            Text(
              '█',
              style: TextStyle(
                color: Colors.white.withOpacity(_animation.value),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}
