import 'package:flutter/material.dart';

class AddNewPostScreen extends StatelessWidget {
  const AddNewPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Add a new post here!'),
      ),
    );
  }
}
