// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CustomThemeSeed extends InheritedWidget {
  final _CustomThemeSeedBuilderState customThemeSeedBuilderState;

  const CustomThemeSeed(
      {Key? key,
      required this.child,
      required this.customThemeSeedBuilderState})
      : super(key: key, child: child);

  final Widget child;

  static CustomThemeSeed? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CustomThemeSeed>();
  }

  @override
  bool updateShouldNotify(CustomThemeSeed oldWidget) {
    return true;
  }
}

class CustomThemeSeedBuilder extends StatefulWidget {
  final Widget child;
  final Color seedColor;
  const CustomThemeSeedBuilder(
      {super.key, required this.child, required this.seedColor});

  @override
  State<CustomThemeSeedBuilder> createState() => _CustomThemeSeedBuilderState();

  static Color? of(BuildContext context) {
    CustomThemeSeed? customThemeSeed =
        (context.dependOnInheritedWidgetOfExactType<CustomThemeSeed>());
    return customThemeSeed?.customThemeSeedBuilderState.seedColor;
  }

  static _CustomThemeSeedBuilderState? instanceOf(BuildContext context) {
    CustomThemeSeed? customThemeSeed =
        (context.dependOnInheritedWidgetOfExactType<CustomThemeSeed>());
    return customThemeSeed?.customThemeSeedBuilderState;
  }
}

class _CustomThemeSeedBuilderState extends State<CustomThemeSeedBuilder> {
  Color seedColor = Colors.purple;

  void changeColor(Color color) {
    debugPrint('changing color!');
    setState(() {
      seedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomThemeSeed(
        customThemeSeedBuilderState: this, child: widget.child);
  }
}
