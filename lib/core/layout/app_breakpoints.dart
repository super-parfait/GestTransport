enum AppPhoneSize {
  compact,
  standard,
  large,
}

abstract final class AppBreakpoints {
  static const double compactWidth = 360;
  static const double largePhoneWidth = 430;
  static const double compactContentMaxWidth = double.infinity;
  static const double largeContentMaxWidth = 520;
  static const double formMaxWidth = 460;

  static AppPhoneSize phoneSize(double width) {
    if (width < compactWidth) {
      return AppPhoneSize.compact;
    }
    if (width >= largePhoneWidth) {
      return AppPhoneSize.large;
    }
    return AppPhoneSize.standard;
  }

  static bool isCompact(double width) =>
      phoneSize(width) == AppPhoneSize.compact;

  static bool isLargePhone(double width) =>
      phoneSize(width) == AppPhoneSize.large;

  static bool useCondensedNavigation(double width) => width < 380;

  static double pagePadding(double width) {
    if (isCompact(width)) {
      return 12;
    }
    if (isLargePhone(width)) {
      return 20;
    }
    return 16;
  }

  static double contentMaxWidth(double width) {
    if (isLargePhone(width)) {
      return largeContentMaxWidth;
    }
    return compactContentMaxWidth;
  }

  static double formContentMaxWidth(double width) {
    if (isLargePhone(width)) {
      return formMaxWidth;
    }
    return double.infinity;
  }

  static int statColumns(double width) {
    if (isCompact(width)) {
      return 1;
    }
    if (isLargePhone(width)) {
      return 3;
    }
    return 2;
  }

  static int quickActionColumns(double width) {
    if (isCompact(width)) {
      return 2;
    }
    if (isLargePhone(width)) {
      return 4;
    }
    return 3;
  }

  static double statTileWidth(double width, {double spacing = 8}) {
    final columns = statColumns(width);
    final totalSpacing = spacing * (columns - 1);
    return ((width - totalSpacing) / columns)
        .clamp(0, double.infinity)
        .toDouble();
  }

  static double quickActionTileWidth(double width, {double spacing = 12}) {
    final columns = quickActionColumns(width);
    final totalSpacing = spacing * (columns - 1);
    final tileWidth = (width - totalSpacing) / columns;
    return tileWidth.clamp(88, 128).toDouble();
  }

  static double dashboardMetricAspectRatio(double width) {
    if (isCompact(width)) {
      return 2.7;
    }
    if (isLargePhone(width)) {
      return 1.55;
    }
    return 1.4;
  }
}
