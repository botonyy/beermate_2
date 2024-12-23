import 'package:flutter/material.dart';
import 'package:beermate_2/services/firestore.dart';

class AddNewPostScreen extends StatelessWidget {
  final FirestoreService firestoreService;

  const AddNewPostScreen({super.key, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('Új poszt hozzáadása'),
    );
  }
}
