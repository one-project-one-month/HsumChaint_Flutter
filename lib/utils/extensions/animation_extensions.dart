import 'package:flutter/material.dart';

extension AnimationX on Widget {
  Widget fadeIn({
    Key? key,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return _AnimatedFadeIn(
      key: key,
      duration: duration,
      delay: delay,
      curve: curve,
      begin: begin,
      end: end,
      child: this,
    );
  }

  Widget scaleIn({
    Key? key,
    Duration duration = const Duration(milliseconds: 700),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOutBack,
    double begin = 0.8,
    double end = 1.0,
    double? fadeBegin,
  }) {
    return _AnimatedScaleIn(
      key: key,
      duration: duration,
      delay: delay,
      curve: curve,
      begin: begin,
      end: end,
      fadeBegin: fadeBegin,
      child: this,
    );
  }

  Widget slideIn({
    Key? key,
    Duration duration = const Duration(milliseconds: 700),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOutCubic,
    Offset begin = const Offset(0, 0.15),
    Offset end = Offset.zero,
    double? fadeBegin,
  }) {
    return _AnimatedSlideIn(
      key: key,
      duration: duration,
      delay: delay,
      curve: curve,
      begin: begin,
      end: end,
      fadeBegin: fadeBegin,
      child: this,
    );
  }

  Widget fadeScaleIn({
    Key? key,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOutBack,
    double scaleBegin = 0.85,
    double scaleEnd = 1.0,
    double opacityBegin = 0.0,
    double opacityEnd = 1.0,
  }) {
    return _AnimatedFadeScaleIn(
      key: key,
      duration: duration,
      delay: delay,
      curve: curve,
      scaleBegin: scaleBegin,
      scaleEnd: scaleEnd,
      opacityBegin: opacityBegin,
      opacityEnd: opacityEnd,
      child: this,
    );
  }
}

class _AnimatedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double begin;
  final double end;

  const _AnimatedFadeIn({
    super.key,
    required this.child,
    required this.duration,
    required this.delay,
    required this.curve,
    required this.begin,
    required this.end,
  });

  @override
  State<_AnimatedFadeIn> createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<_AnimatedFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _start();
  }

  Future<void> _start() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

class _AnimatedScaleIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double begin;
  final double end;
  final double? fadeBegin;

  const _AnimatedScaleIn({
    super.key,
    required this.child,
    required this.duration,
    required this.delay,
    required this.curve,
    required this.begin,
    required this.end,
    this.fadeBegin,
  });

  @override
  State<_AnimatedScaleIn> createState() => _AnimatedScaleInState();
}

class _AnimatedScaleInState extends State<_AnimatedScaleIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  Animation<double>? _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);

    _scale = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(curved);

    if (widget.fadeBegin != null) {
      _opacity = Tween<double>(
        begin: widget.fadeBegin!,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    }

    _start();
  }

  Future<void> _start() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = ScaleTransition(scale: _scale, child: widget.child);
    if (_opacity != null) {
      child = FadeTransition(opacity: _opacity!, child: child);
    }
    return child;
  }
}

class _AnimatedSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset begin;
  final Offset end;
  final double? fadeBegin;

  const _AnimatedSlideIn({
    super.key,
    required this.child,
    required this.duration,
    required this.delay,
    required this.curve,
    required this.begin,
    required this.end,
    this.fadeBegin,
  });

  @override
  State<_AnimatedSlideIn> createState() => _AnimatedSlideInState();
}

class _AnimatedSlideInState extends State<_AnimatedSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  Animation<double>? _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _offset = Tween<Offset>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.fadeBegin != null) {
      _opacity = Tween<double>(
        begin: widget.fadeBegin!,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    }

    _start();
  }

  Future<void> _start() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = SlideTransition(position: _offset, child: widget.child);
    if (_opacity != null) {
      child = FadeTransition(opacity: _opacity!, child: child);
    }
    return child;
  }
}

class _AnimatedFadeScaleIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double scaleBegin;
  final double scaleEnd;
  final double opacityBegin;
  final double opacityEnd;

  const _AnimatedFadeScaleIn({
    super.key,
    required this.child,
    required this.duration,
    required this.delay,
    required this.curve,
    required this.scaleBegin,
    required this.scaleEnd,
    required this.opacityBegin,
    required this.opacityEnd,
  });

  @override
  State<_AnimatedFadeScaleIn> createState() => _AnimatedFadeScaleInState();
}

class _AnimatedFadeScaleInState extends State<_AnimatedFadeScaleIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scale = Tween<double>(
      begin: widget.scaleBegin,
      end: widget.scaleEnd,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _opacity = Tween<double>(
      begin: widget.opacityBegin,
      end: widget.opacityEnd,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _start();
  }

  Future<void> _start() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
