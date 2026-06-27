import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.height = 16, this.width = double.infinity, this.radius = 8});
  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceVariant;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: baseColor.withOpacity(0.5),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}

class SkeletonCardList extends StatelessWidget {
  const SkeletonCardList({super.key, this.count = 3, this.cardHeight = 84});
  final int count;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonBox(height: cardHeight, radius: 18),
        ),
      ),
    );
  }
}
