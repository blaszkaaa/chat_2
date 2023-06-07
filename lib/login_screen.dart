import 'package:chat_2/chat_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logged_in_screen.dart';
import 'register_screen.dart';

class LogInScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logowanie'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[800]!, Colors.blue[400]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff667eea), Color(0xff764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                style: TextStyle(color: Colors.grey[800]),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey[800]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[900]!),
                  ),
                ),
              ),
              SizedBox(height: 10), // Adds some space between the fields
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.grey[800]),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  hintText: 'Hasło',
                  hintStyle: TextStyle(color: Colors.grey[800]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[900]!),
                  ),
                ),
              ),
              ElevatedButton(
                child: Text('Zaloguj'),
                onPressed: () {
                  _auth.signInWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  ).then((UserCredential userCredential) {
                    if(userCredential.user != null) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => ChatListScreen()));
                    } else {
                      print("Nie udało się zalogować użytkownika.");
                    }
                  }).catchError((e) {
                    print(e);
                  });
                },
              ),
              ElevatedButton(
                child: Text('Zarejestruj się'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RegisterScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
