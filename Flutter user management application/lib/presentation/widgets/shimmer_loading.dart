import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  
  const ShimmerLoading({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }
}

class ShimmerUserListItem extends StatelessWidget {
  const ShimmerUserListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200,
                height: 20,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                width: 300,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerUserDetails extends StatelessWidget {
  const ShimmerUserDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 30,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
          ),
          Container(
            width: 300,
            height: 20,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          Container(
            width: 250,
            height: 20,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
          ),
          Container(
            width: 200,
            height: 20,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          Container(
            width: 300,
            height: 20,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
          ),
          Container(
            width: 150,
            height: 20,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          Container(
            width: 250,
            height: 20,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
          ),
        ],
      ),
    );
  }
}