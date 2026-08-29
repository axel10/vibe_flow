import 'package:flutter/material.dart';
import 'package:vynody/widgets/app_tooltip.dart';

class AnimatedPlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color color;
  final double size;
  final String? tooltip;
  final EdgeInsetsGeometry padding;
  final MaterialTapTargetSize? materialTapTargetSize;

  const AnimatedPlayPauseButton({
    super.key,
    required this.isPlaying,
    this.isLoading = false,
    required this.onPressed,
    required this.color,
    required this.size,
    this.tooltip,
    this.padding = EdgeInsets.zero,
    this.materialTapTargetSize,
  });

  @override
  State<AnimatedPlayPauseButton> createState() => _AnimatedPlayPauseButtonState();
}

class _AnimatedPlayPauseButtonState extends State<AnimatedPlayPauseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: widget.isPlaying ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedPlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: widget.isLoading
            ? Center(
                key: const ValueKey('loading'),
                child: SizedBox(
                  width: (widget.size * 0.54).clamp(14.0, 36.0),
                  height: (widget.size * 0.54).clamp(14.0, 36.0),
                  child: CircularProgressIndicator(
                    strokeWidth: (widget.size * 0.075).clamp(1.8, 3.2),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                  ),
                ),
              )
            : Center(
                key: const ValueKey('icon'),
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _animationController,
                  color: widget.color,
                  size: widget.size,
                ),
              ),
      ),
    );

    final Widget buttonWidget = IconButton(
      onPressed: widget.onPressed,
      padding: widget.padding,
      constraints: const BoxConstraints(),
      style: widget.materialTapTargetSize != null
          ? IconButton.styleFrom(tapTargetSize: widget.materialTapTargetSize)
          : null,
      icon: iconWidget,
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      return AppTooltip(
        message: widget.tooltip!,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}
