import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final Alignment alignment;
  final bool shrinkWrapHeight;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
    this.shrinkWrapHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Align(
      alignment: alignment,
      heightFactor: shrinkWrapHeight ? 1 : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? AppBreakpoints.contentMaxWidth(width),
        ),
        child: child,
      ),
    );
  }
}
