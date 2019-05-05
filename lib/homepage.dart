import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatbook/chat_page.dart';
import 'package:chatbook/sharedPrefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  GoogleSignIn googleSignIn = GoogleSignIn();

  SharedPreferences sharedPrefrences;
  @override
  void initState() {
    super.initState();
    initSharedPrefs();
  }

  initSharedPrefs() async {
    sharedPrefrences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              await firebaseAuth.signOut();
              await googleSignIn.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            QuerySnapshot data = snapshot.data;
            return ((snapshot.hasData)
                ? ListView.builder(
                    itemBuilder: (context, index) {
//                      return Text(data['nickname']);
                      return BuildItem(data.documents[index]);
                    },
                    itemCount: snapshot.data.documents.length,
                  )
                : Center(child: CircularProgressIndicator()));
          }),
    );
  }

  BuildItem(DocumentSnapshot item) {
    return (sharedPrefrences.get(CURRENT_ID) != item.data['id'])
        ? GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatPage(item)));
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  CachedNetworkImage(
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    imageUrl: item.data[PHOTO],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    child: Text(item.data['nickname']),
                  )
                ],
              ),
            ),
          )
        : Container();
  }
}
