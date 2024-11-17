import 'package:beermate_2/reuseable_widgets/reuseable_widgets.dart';
import 'package:beermate_2/screens/profile_screen.dart';
import 'package:beermate_2/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();

    // Az oldalak inicializálása
    _screens.addAll([
      HomePageContent(textController: textController),
      const Placeholder(),
      const Placeholder(),
      const Placeholder(),
      const ProfileScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void openPostBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Add meg a poszt szövegét'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                firestoreService.addPost(textController.text);
              } else {
                firestoreService.updatePost(docID, textController.text);
              }
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text("Mentés"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBackButton: false),
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: Align(
          alignment: const Alignment(1.0, 0.9),
          child: FloatingActionButton(
            onPressed: () {
              openPostBox(); // Poszt hozzáadása
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class HomePageContent extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController;

  HomePageContent({super.key, required this.textController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Hiba történt!"));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Nincsenek adatok."));
        }

        final postsList = snapshot.data!.docs;
        return ListView.builder(
          itemCount: postsList.length,
          itemBuilder: (context, index) {
            final document = postsList[index];
            final data = document.data() as Map<String, dynamic>;
            final postText = data["post"] ?? "N/A";

            return ListTile(
              title: Text(postText),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      textController.text = postText;
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: TextField(
                            controller: textController,
                            decoration: const InputDecoration(hintText: 'Módosítsd a posztot'),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                firestoreService.updatePost(document.id, textController.text);
                                Navigator.pop(context);
                              },
                              child: const Text("Mentés"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      firestoreService.deletePost(document.id);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
