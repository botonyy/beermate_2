import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.keyboardType,
    required this.obscureText,
    required this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        prefixIcon: Icon(prefixIcon),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final double width;
  final double height;
  final VoidCallback onPressed;
  final TextStyle textStyle;
  final BorderRadiusGeometry borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color.fromARGB(255, 209, 208, 208),
    this.width = 280,
    this.height = 50,
    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(textStyle),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          elevation: WidgetStateProperty.all(0),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}

//CustomAppBar

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //leading: const Icon(Icons.account_circle_rounded), // Bal oldali ikon
      title: const Text(
        'BeerMate',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      /*
      actions: [
        IconButton(
          icon: const Icon(Icons.search), // Jobb oldali ikon
          onPressed: () {
            // Ide jöhet az akció, ha szükséges
          },
        ),
      ],
      */
      backgroundColor: const Color.fromARGB(255, 219, 215, 215), // Szürke hátteret állít be
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.0), // Alsó bal sarok lekerekítése
          bottomRight: Radius.circular(30.0),
        ),
      ),
    );
  }
  

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
