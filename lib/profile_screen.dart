import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final _faker = Faker();
  String? _userImageUrl;

  String get randomImageUrl =>
      'https://picsum.photos/200/300?random=${_faker.randomGenerator.integer(1000)}';

  @override
  void initState() {
    super.initState();
    _getUserImageUrl();
  }

  Future<void> _getUserImageUrl() async {
    DocumentSnapshot userSnapshot =
        await _db.collection('users').doc(_currentUser?.uid).get();

    if (userSnapshot.data() != null) {
      Map<String, dynamic>? data = userSnapshot.data() as Map<String, dynamic>?;

      if (data?['imageUrl'] != null) {
        setState(() {
          _userImageUrl = data?['imageUrl'];
        });
      } else {
        String imageUrl = randomImageUrl;
        await userSnapshot.reference.update({'imageUrl': imageUrl});
        setState(() {
          _userImageUrl = imageUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(_userImageUrl ?? ''),
            ),
            SizedBox(height: 20),
            Text(
              _currentUser!.email!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Zmień hasło'),
              onPressed: () {
                // TODO: Implement password change
              },
            ),
          ],
        ),
      ),
    );
  }
}
