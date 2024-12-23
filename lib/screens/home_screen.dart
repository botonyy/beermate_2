import 'package:beermate_2/reuseable_widgets/reuseable_widgets.dart';
import 'package:beermate_2/screens/add_post_screen.dart';
import 'package:beermate_2/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beermate_2/screens/friend_mgmt_screen.dart';
import 'package:beermate_2/screens/profile_screen.dart';
import 'package:beermate_2/screens/rating_screen.dart';
import 'package:beermate_2/services/firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final FirestoreService firestoreService;

  const HomeScreen({super.key, required this.firestoreService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomePageContent(
        firestoreService: widget.firestoreService,
        textController: TextEditingController(),
      ),
      ChatScreen(firestoreService: widget.firestoreService),
      AddNewPostScreen(firestoreService: widget.firestoreService),
      RatingScreen(firestoreService: widget.firestoreService),
      ProfileScreen(),
    ];
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'BeerMate';
      case 1:
        return 'Chat';
      case 2:
        return 'Új poszt hozzáadása';
      case 3:
        return 'Értékelés';
      case 4:
        return 'Profil';
      default:
        return 'BeerMate';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getAppBarTitle(),
        showBackButton: false,
        showFriendsButton: true,
        onNavigateToFriendMgmt: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FriendManagementScreen(
                firestoreService: widget.firestoreService,
              ),
            ),
          );
        },
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final FirestoreService firestoreService;
  final TextEditingController textController;

  const HomePageContent({
    super.key,
    required this.firestoreService,
    required this.textController,
  });

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
