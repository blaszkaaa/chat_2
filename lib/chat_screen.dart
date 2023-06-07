import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;

  ChatScreen({required this.chatId, required this.chatName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final _messageController = TextEditingController();
  String? _username;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  fetchUsername() async {
    DocumentSnapshot userDoc =
        await _db.collection('users').doc(_currentUser?.uid).get();
    setState(() {
      _username = userDoc['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Błąd: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    var messageData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    bool isCurrentUser = messageData['userId'] == _currentUser?.uid;
                    return Row(
                      mainAxisAlignment:
                          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          decoration: BoxDecoration(
                            color: isCurrentUser ? Colors.blue[200] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                messageData['username'] ?? 'Anonimowy',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(messageData['text'] ?? ''),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: bottomPadding, left: 10, right: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Wpisz wiadomość...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty && _username != null) {
                      _db.collection('chats').doc(widget.chatId).collection('messages').add({
                        'userId': _currentUser?.uid,
                        'username': _username,
                        'text': _messageController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
