import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:beermate_2/services/firestore.dart';

class FriendManagementScreen extends StatelessWidget {
  final FirestoreService firestoreService;

  const FriendManagementScreen({super.key, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    final CollectionReference friends =
        FirebaseFirestore.instance.collection('friends');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barátkezelés'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 219, 215, 215),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: friends.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Hiba történt!'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nincsenek barátok.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.yellow,
                ),
              ),
            );
          }

          final friendList = snapshot.data!.docs;

          return ListView.separated(
            itemCount: friendList.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.grey,
            ),
            itemBuilder: (context, index) {
              final friend = friendList[index];
              final data = friend.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(
                  data['name'] ?? 'Ismeretlen',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        // Elfogadás logikája
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        // Elutasítás logikája
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
