import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String photoUrl;
  final String email;
  final String displayName;
  final String bio;
  User({
    this.username,
    this.displayName,
    this.email,
    this.photoUrl,
    this.id,
    this.bio,
  });
  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      username: doc['username'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      bio: doc['bio'],
      displayName: doc['displayName'],
    );
  }
}
