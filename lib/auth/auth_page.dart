import 'package:chatbook/homepage.dart';
import 'package:chatbook/sharedPrefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth Page'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            _googleSignIn().then((user) async {
              if (user != null) {
                final QuerySnapshot result = await Firestore.instance
                    .collection('users')
                    .where('id', isEqualTo: user.uid)
                    .getDocuments();
                if (result.documents.length == 0) {
                  Firestore().collection('users').document(user.uid).setData({
                    'nickname': user.displayName,
                    'photoUrl': user.photoUrl,
                    'id': user.uid
                  }).then((res) {
                    saveInSharedPref(user);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  });
                } else {
                  saveInSharedPref(user);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                }
              } else {}
            });
          },
          child: Text('Login'),
        ),
      ),
    );
  }

  Future<FirebaseUser> _googleSignIn() async {
    var googleSignInAccount = await googleSignIn.signIn();
    var googleSignInAuthentication = await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final FirebaseUser user =
        await _firebaseAuth.signInWithCredential(credential);
    return user;
  }
}

saveInSharedPref(FirebaseUser user) async {
  SharedPreferences sharedPrefrences = await SharedPreferences.getInstance();
  sharedPrefrences.setString(CURRENT_ID, user.uid);
  sharedPrefrences.setString(NICKNAME, user.displayName);
  sharedPrefrences.setString(PHOTO, user.photoUrl);
}
