import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final Alignment alignment;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? AppBreakpoints.contentMaxWidth(width),
        ),
        child: child,
      ),
    );
  }
}
