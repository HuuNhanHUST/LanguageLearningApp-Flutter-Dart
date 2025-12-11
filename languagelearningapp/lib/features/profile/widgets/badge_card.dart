import 'package:flutter/material.dart';

import '../models/badge_model.dart';

class BadgeCard extends StatelessWidget {
  final BadgeModel badge;

  const BadgeCard({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = badge.isUnlocked;
    final ColorFilter? grayscaleFilter = isUnlocked
        ? null
        : const ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0, 0, 0, 1, 0,
          ]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? Colors.amber : Colors.white24,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColorFiltered(
            colorFilter: grayscaleFilter ?? const ColorFilter.mode(
                Colors.transparent, BlendMode.srcIn),
            child: Text(
              badge.icon,
              style: const TextStyle(fontSize: 36),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              badge.description,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.green.withOpacity(0.2) : Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isUnlocked ? 'Đã đạt được' : badge.condition,
              style: TextStyle(
                color: isUnlocked ? Colors.greenAccent : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
