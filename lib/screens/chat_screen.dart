import 'package:flutter/material.dart';
import 'package:beermate_2/services/firestore.dart';

class ChatScreen extends StatelessWidget {
  final FirestoreService firestoreService;

  const ChatScreen({super.key, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('Ez a Chat képernyő'),
      );
  }
}
