import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBurst extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final VoidCallback? onComplete;

  const ParticleBurst({
    super.key,
    required this.child,
    required this.trigger,
    this.onComplete,
  });

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _particles = <_Particle>[];
  final _rng = Random();

  static const _colors = [
    Color(0xFF6C63FF),
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.red,
  ];


  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }


  @override
  void didUpdateWidget(ParticleBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger) {
      _particles
        ..clear()
        ..addAll(List.generate(14, (_) => _Particle(
          angle: _rng.nextDouble() * 2 * pi,
          speed: 35 + _rng.nextDouble() * 65,
          size: 4 + _rng.nextDouble() * 4,
          color: _colors[_rng.nextInt(_colors.length)],
        )));
      _ctrl.forward(from: 0);
    }
  }


  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        if (_particles.isEmpty || _ctrl.value == 0) return child!;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child!,
            for (final p in _particles)
              Positioned(
                left: 24 + cos(p.angle) * p.speed * _ctrl.value,
                top: 8 + sin(p.angle) * p.speed * _ctrl.value -
                    30 * _ctrl.value, // slight upward drift
                child: Opacity(
                  opacity: (1 - _ctrl.value).clamp(0.0, 1.0),
                  child: Container(
                    width: p.size,
                    height: p.size,
                    decoration: BoxDecoration(
                      color: p.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}
