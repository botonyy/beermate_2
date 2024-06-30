import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('posts');

  //CREATE
  Future<void> addPost(String post) {
    return posts.add({
      'post': post,
      'timestamp': Timestamp.now(),
    });
  }

  //READ
  Stream<QuerySnapshot> getPostsStream() {
    final postsStream =
        posts.orderBy('timestamp', descending: true).snapshots();
    return postsStream;
  }

  //UPDATE
  Future<void> updatePost(String docID, String newPost){
    return posts.doc(docID).update({
      'post': newPost,
      'timestamp': Timestamp.now(),
    });
  }

  //DELETE
  Future<void> deletePost(String docID) {
    return posts.doc(docID).delete();
  }


}
