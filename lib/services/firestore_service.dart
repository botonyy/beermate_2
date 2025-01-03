import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Singleton instance
  static final FirestoreService _instance = FirestoreService._internal();

  // Factory constructor to return the same instance
  factory FirestoreService() {
    return _instance;
  }

  // Private constructor
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kollekciók
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get friends => _firestore.collection('friends');
  CollectionReference get posts => _firestore.collection('posts');
  CollectionReference get drinks => _firestore.collection('drinks');
  CollectionReference get ratings => _firestore.collection('ratings');
  CollectionReference get chats => _firestore.collection('chats');

  // --- FELHASZNÁLÓK (USERS) ---
  Future<void> createUser(String userId, String username, String email) async {
    return users.doc(userId).set({
      'username': username,
      'email': email,
      'created_at': FieldValue.serverTimestamp(),
      'profile_picture': '',
      'phone': '',
    });
  }

  Future<DocumentSnapshot> getUser(String userId) async {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    return users.doc(userId).update(data);
  }

  // --- BARÁTOK (FRIENDS) ---
  Future<void> addFriend(String userId, String friendId) async {
    await friends.add({
      'user_id_1': userId,
      'user_id_2': friendId,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getFriends(String userId) {
    return friends
        .where('user_id_1', isEqualTo: userId)
        .snapshots();
  }

  Future<void> updateFriendStatus(String docId, String status) async {
    return friends.doc(docId).update({'status': status});
  }

  // --- POSZTOK (POSTS) ---
  Future<void> addPost(
    String userId,
    String content,
    String postType,
    bool isPublic,
    String? imageUrl,
  ) async {
    try {
      await _firestore.collection("posts").add({
        "user_id": userId,
        "content": content,
        "type": postType,
        "is_public": isPublic,
        "image_url": imageUrl ?? "",
        "created_at": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Hiba a poszt hozzáadása során: $e");
    }
  }

  Stream<QuerySnapshot> getPostsStream() {
    return posts.orderBy('created_at', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getUserPosts(String userId) {
    return posts.where('user_id', isEqualTo: userId).snapshots();
  }

  Future<void> updatePost(String docID, String newContent) {
    return posts.doc(docID).update({
      'content': newContent,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePost(String docID) {
    return posts.doc(docID).delete();
  }

  // --- ITALOK (DRINKS) ---
  Future<DocumentReference> addDrink(String name, String category) async {
    return drinks.add({
      'name': name,
      'category': category,
      'average_rating': 0,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getAllDrinks() {
    return drinks.orderBy('created_at', descending: true).snapshots();
  }

  Future<void> updateDrinkRating(String drinkId, double newRating) async {
    return drinks.doc(drinkId).update({'average_rating': newRating});
  }

  // --- ÉRTÉKELÉSEK (RATINGS) ---
  Future<DocumentReference> addRating(
    String drinkId,
    String userId,
    double rating,
    String review,
  ) async {
    return ratings.add({
      'drink_id': drinkId,
      'user_id': userId,
      'rating_value': rating,
      'review': review,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getRatingsForDrink(String drinkId) {
    return ratings.where('drink_id', isEqualTo: drinkId).snapshots();
  }

  // --- ÜZENETEK (CHATS) ---
  Future<void> createChat(String chatId, List<String> participants) async {
    return chats.doc(chatId).set({
      'participants': participants,
      'messages': [],
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendMessage(String chatId, String senderId, String message) async {
    return chats.doc(chatId).update({
      'messages': FieldValue.arrayUnion([
        {
          'sender_id': senderId,
          'message': message,
          'sent_at': FieldValue.serverTimestamp(),
        }
      ]),
    });
  }

  Stream<DocumentSnapshot> getChat(String chatId) {
    return chats.doc(chatId).snapshots();
  }

  Stream<QuerySnapshot> getUserChats(String userId) {
    return chats.where('participants', arrayContains: userId).snapshots();
  }
}
