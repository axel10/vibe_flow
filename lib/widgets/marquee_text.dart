import 'dart:async';
import 'package:flutter/material.dart';

/// A custom marquee text widget that automatically scrolls horizontally
/// back-and-forth if the text width exceeds the available container width.
class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Alignment alignment;
  final Duration scrollDelay;
  final double velocity; // Speed in logical pixels per second

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.alignment = Alignment.centerLeft,
    this.scrollDelay = const Duration(seconds: 2),
    this.velocity = 35.0,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  Timer? _debounceTimer;
  int _currentCycleId = 0;
  double? _lastWidth;

  @override
  void didUpdateWidget(covariant MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.style != widget.style ||
        oldWidget.alignment != widget.alignment) {
      _checkAndStartScroll();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkAndStartScroll() {
    if (!mounted) return;

    // Cancel any active debounce timers
    _debounceTimer?.cancel();

    // Instantly reset the scroll offset during layout/style changes to keep UI stable
    if (_scrollController.hasClients && _scrollController.offset != 0.0) {
      _scrollController.jumpTo(0.0);
    }

    // Debounce the overflow measurement and scrolling initialization.
    // This allows complex screen layouts (like lyrics mode transitions)
    // to finish animating before we measure text width and trigger scroll.
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _scrollTimer?.cancel();
      _currentCycleId++;
      final cycleId = _currentCycleId;

      if (!_scrollController.hasClients) return;
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      if (maxScrollExtent > 0) {
        _startScrollCycle(cycleId, maxScrollExtent);
      }
    });
  }

  void _startScrollCycle(int cycleId, double maxScrollExtent) {
    if (!mounted || cycleId != _currentCycleId) return;

    _scrollTimer = Timer(widget.scrollDelay, () async {
      if (!mounted || cycleId != _currentCycleId) return;

      final duration = Duration(
        milliseconds: (maxScrollExtent / widget.velocity * 1000).round(),
      );

      // Scroll to the end
      try {
        await _scrollController.animateTo(
          maxScrollExtent,
          duration: duration,
          curve: Curves.linear,
        );
      } catch (_) {
        // Animation was cancelled or failed (e.g. by jumpTo/animateTo elsewhere)
      }

      if (!mounted || cycleId != _currentCycleId) return;

      // Pause at the end
      _scrollTimer = Timer(widget.scrollDelay, () async {
        if (!mounted || cycleId != _currentCycleId) return;

        // Scroll back to the start
        try {
          await _scrollController.animateTo(
            0.0,
            duration: duration,
            curve: Curves.linear,
          );
        } catch (_) {
          // Animation was cancelled or failed
        }

        if (!mounted || cycleId != _currentCycleId) return;

        // Loop the cycle
        _startScrollCycle(cycleId, maxScrollExtent);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_lastWidth != constraints.maxWidth) {
          _lastWidth = constraints.maxWidth;
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndStartScroll());
        }

        return Semantics(
          label: widget.text,
          child: ExcludeSemantics(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Align(
                  alignment: widget.alignment,
                  child: Text(
                    widget.text,
                    style: widget.style,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
