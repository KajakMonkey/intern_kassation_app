import 'package:flutter/material.dart';
import 'package:intern_kassation_app/ui/core/extensions/buildcontext_extension.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({
    required this.child,
    super.key,
    this.baseColor,
    this.highlightColor,
  });

  const ShimmerEffect.listTile({
    super.key,
    this.baseColor,
    this.highlightColor,
  }) : child = const ListTile(
         title: Align(
           alignment: Alignment.centerLeft,
           child: SizedBox(
             width: 150,
             height: 10,
             child: DecoratedBox(
               decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
             ),
           ),
         ),
         subtitle: Align(
           alignment: Alignment.centerLeft,
           child: SizedBox(
             width: 200,
             height: 10,
             child: DecoratedBox(
               decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
             ),
           ),
         ),
       );

  final Color? baseColor;
  final Color? highlightColor;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? context.shimmer.baseColor,
      highlightColor: highlightColor ?? context.shimmer.highlightColor,
      child: child,
    );
  }
}
