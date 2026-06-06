import 'package:flutter/widgets.dart';

enum DeviceClass { mobile, tablet, desktop }

class Breakpoints {
  const Breakpoints._();

  static const double mobile = 600;
  static const double desktop = 1024;

  static DeviceClass of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobile) return DeviceClass.mobile;
    if (width <= desktop) return DeviceClass.tablet;
    return DeviceClass.desktop;
  }

  static bool isMobile(BuildContext context) => of(context) == DeviceClass.mobile;
  static bool isTablet(BuildContext context) => of(context) == DeviceClass.tablet;
  static bool isDesktop(BuildContext context) => of(context) == DeviceClass.desktop;
}
