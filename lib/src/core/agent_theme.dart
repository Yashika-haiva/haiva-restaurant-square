import 'package:flutter/material.dart';

import '../shared/consts.dart';

final agentTheme = ThemeData(
  scaffoldBackgroundColor: whiteColor,
  primaryColor: primaryColor,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: secondaryColor),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    iconTheme: IconThemeData(color: whiteColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.all(
        textStyleS14W400.copyWith(color: whiteColor),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (states) =>
            states.contains(WidgetState.disabled)
                ? disabledButtonColor
                : primaryColor,
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (states) => whiteColor,
      ),
    ),
  ),
);
