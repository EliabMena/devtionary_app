import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color hintColor;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const CustomSearchBar({
    Key? key,
    this.controller,
    this.hintText = 'Buscar...',
    this.onChanged,
    this.onSubmitted,
    this.backgroundColor = const Color(0xFF2C2C2C),
    this.textColor = Colors.white,
    this.iconColor = const Color(0xFF9E9E9E),
    this.hintColor = const Color(0xFF9E9E9E),
    this.height = 50.0,
    this.borderRadius = 25.0,
    this.margin,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: TextStyle(color: textColor, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: iconColor, size: 20),
          hintText: hintText,
          hintStyle: TextStyle(color: hintColor, fontSize: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
