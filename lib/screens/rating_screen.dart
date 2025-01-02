import 'package:flutter/material.dart';
import 'package:beermate_2/services/firestore_service.dart';

class RatingScreen extends StatelessWidget {
  final FirestoreService firestoreService;

  const RatingScreen({super.key, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Értékelés'), // Scaffold eltávolítva
    );
  }
}
