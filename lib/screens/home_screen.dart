import 'package:beermate_2/reuseable_widgets/reuseable_widgets.dart';
import 'package:beermate_2/screens/add_post_screen.dart';
import 'package:beermate_2/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beermate_2/screens/friend_mgmt_screen.dart';
import 'package:beermate_2/screens/profile_screen.dart';
import 'package:beermate_2/screens/rating_screen.dart';
import 'package:beermate_2/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
              builder: (context) => const FriendManagementScreen(), // Távolítsd el a firestoreService paramétert
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

  const HomePageContent({
    super.key,
    required this.firestoreService,
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
          return const Center(child: Text("Nincsenek posztok."));
        }

        final postsList = snapshot.data!.docs;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        return ListView.builder(
          itemCount: postsList.length,
          itemBuilder: (context, index) {
            final document = postsList[index];
            final data = document.data() as Map<String, dynamic>;
            final userId = data['user_id'] ?? "unknown";
            final postText = data['content'] ?? "N/A";
            final imageUrl = data['image_url'] ?? null;

            return FutureBuilder<DocumentSnapshot>(
              future: firestoreService.getUser(userId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (userSnapshot.hasError ||
                    !userSnapshot.hasData ||
                    !userSnapshot.data!.exists) {
                  return const ListTile(
                    title: Text("Ismeretlen felhasználó"),
                    subtitle: Text("Hiba történt a felhasználónév betöltésekor."),
                  );
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                final username = userData['username'] ?? "Ismeretlen";

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 20,
                                  child: Icon(Icons.person),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  username,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            if (currentUserId == userId)
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _showDeleteDialog(context, document.id);
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (imageUrl != null)
                          AspectRatio(
                            aspectRatio: 3 / 4,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Text('Hiba a kép betöltésekor')),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(postText),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () {
                                // Like gomb logikája
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.comment),
                              onPressed: () {
                                // Komment gomb logikája
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Poszt törlése"),
        content: const Text("Biztosan törölni szeretnéd ezt a posztot?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Mégse"),
          ),
          ElevatedButton(
            onPressed: () {
              firestoreService.deletePost(postId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Poszt törölve.")),
              );
            },
            child: const Text("Törlés"),
          ),
        ],
      ),
    );
  }
}
