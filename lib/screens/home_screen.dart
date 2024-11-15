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

final List<Widget> _screens = [
    HomePageContent(),
    Placeholder(), // Chat screen helye
    Placeholder(), // Add post (FloatingActionButton kezeli)
    Placeholder(), // Rate screen helye
    ProfileScreen(), // Profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
              openPostBox(); // Add post művelet
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void openPostBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
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
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<DocumentSnapshot> postsList = snapshot.data!.docs;
          return SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: postsList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = postsList[index];
                String docID = document.id;
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String postText = data["post"];

                return ListTile(
                  title: Text(postText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: TextField(
                                controller: TextEditingController(text: postText),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    firestoreService.updatePost(docID, postText);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Update"),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings),
                      ),
                      IconButton(
                        onPressed: () => firestoreService.deletePost(docID),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
