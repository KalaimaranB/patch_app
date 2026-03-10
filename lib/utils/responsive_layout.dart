import 'package:flutter/widgets.dart';

/// Responsive layout utility for adaptive UI across phones, tablets, and iPads.
class AppLayout {
  AppLayout._();

  static const double _tabletBreakpoint = 600;
  static const double _largeTabletBreakpoint = 900;
  static const double maxContentWidth = 700;

  /// True for tablets (>= 600px width).
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _tabletBreakpoint;

  /// True for large tablets like iPad Pro (>= 900px width).
  static bool isLargeTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _largeTabletBreakpoint;

  /// Returns adaptive padding based on screen size.
  static EdgeInsets padding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= _largeTabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 20);
    } else if (width >= _tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
    return const EdgeInsets.all(20);
  }

  /// Returns a BoxConstraints with max width for content centering on tablets.
  static BoxConstraints contentConstraints(BuildContext context) {
    return BoxConstraints(
      maxWidth: isTablet(context) ? maxContentWidth : double.infinity,
    );
  }

  /// Wraps content in a centered, width-constrained container for tablet.
  /// On phones, content stretches normally.
  static Widget constrainContent({
    required BuildContext context,
    required Widget child,
  }) {
    if (!isTablet(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: contentConstraints(context),
        child: child,
      ),
    );
  }
}
