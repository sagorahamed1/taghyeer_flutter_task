import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';
import 'particle_burst.dart';

class TransactionTile extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile>
    with SingleTickerProviderStateMixin {
  // unbounded so spring can overshoot past 0
  late final AnimationController _spring;
  double _dragX = 0;
  bool _burstTriggered = false;

  // how far left before we commit to delete
  static const _threshold = -85.0;

  @override
  void initState() {
    super.initState();
    _spring = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _spring.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _spring.stop();
    setState(() {
      _dragX = (_dragX + d.delta.dx).clamp(-200.0, 0.0);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final vel = d.velocity.pixelsPerSecond.dx;

    if (_dragX < _threshold) {
      // fling off screen, trigger burst, then call onDelete
      _spring.value = _dragX;
      _spring.animateWith(_makeSpring(_dragX, -400, vel)).then((_) {
        if (mounted) setState(() => _burstTriggered = true);
      });
    } else {
      // spring back to resting position
      _spring.value = _dragX;
      _spring.animateWith(_makeSpring(_dragX, 0, vel));
      setState(() => _dragX = 0);
    }
  }

  SpringSimulation _makeSpring(double from, double to, double vel) {
    return SpringSimulation(
      const SpringDescription(mass: 1, stiffness: 220, damping: 22),
      from,
      to,
      vel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ParticleBurst(
      trigger: _burstTriggered,
      onComplete: widget.onDelete,
      child: Stack(
        children: [
          // red delete hint behind the card
          Positioned.fill(
            child: Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.only(left: 20),
              child: Icon(Icons.delete_outline, color: Colors.red.shade400),
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: AnimatedBuilder(
              animation: _spring,
              builder: (_, child) => Transform.translate(
                offset: Offset(_dragX != 0 ? _dragX : _spring.value, 0),
                child: child,
              ),
              child: _TileCard(transaction: widget.transaction),
            ),
          ),
        ],
      ),
    );
  }
}

class _TileCard extends StatelessWidget {
  final Transaction transaction;

  const _TileCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _CategoryIcon(category: transaction.category),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${transaction.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('MMM d').format(transaction.date),
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String category;

  const _CategoryIcon({required this.category});

  static const _icons = <String, IconData>{
    'Food': Icons.restaurant_outlined,
    'Transport': Icons.directions_car_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Health': Icons.medical_services_outlined,
    'Entertainment': Icons.movie_outlined,
  };

  static const _colors = <String, Color>{
    'Food': Color(0xFFFF6B6B),
    'Transport': Color(0xFF4ECDC4),
    'Shopping': Color(0xFFFFBE0B),
    'Health': Color(0xFF06D6A0),
    'Entertainment': Color(0xFFAB47BC),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[category] ?? const Color(0xFF6C63FF);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _icons[category] ?? Icons.attach_money,
        color: color,
        size: 22,
      ),
    );
  }
}
