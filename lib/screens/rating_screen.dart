import 'package:flutter/material.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'This is the Rating screen.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
