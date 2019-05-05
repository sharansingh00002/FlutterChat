import 'package:chatbook/sharedPrefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  DocumentSnapshot peer;
  ChatPage(this.peer);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String groupChatId;
  final TextEditingController textEditingController = TextEditingController();
  SharedPreferences sharedPreferences;
  QuerySnapshot dataList;

  @override
  void initState() {
    super.initState();
    initData();
    Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CHAT'),
      ),
      body: Stack(
        children: <Widget>[
          StreamBuilder(
            stream: Firestore.instance
                .collection('messages')
                .document(groupChatId)
                .collection(groupChatId)
                .orderBy('timestamp', descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, snapshot) {
              if ((dataList != null) ||
                  snapshot.data != null && snapshot.hasData) {
                if (dataList != snapshot.data) {
                  dataList = snapshot.data;
                }
                return Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: ListView.builder(
                    itemBuilder: (context, index) => BuildItem(
                          data: dataList
                              .documents[dataList.documents.length - index - 1],
                          index: index,
                        ),
                    itemCount: snapshot.data.documents.length,
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Positioned(
            bottom: 0,
            child: Container(
              color: Colors.blue,
              height: 60,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    width: 250,
                    child: TextField(
                      controller: textEditingController,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage(textEditingController.value.text);
                      textEditingController.clear();
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  sendMessage(String message) {
    if (message != null && message.isNotEmpty) {
      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': sharedPreferences.get(CURRENT_ID),
            'idTo': widget.peer.data['id'],
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': message,
            'type': 'text',
          },
        );
      });
    }
  }

  BuildItem({DocumentSnapshot data, int index}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        data.data['content'],
        textAlign: (data.data['idFrom'] == sharedPreferences.get(CURRENT_ID))
            ? TextAlign.end
            : TextAlign.start,
      ),
    );
  }

  initData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    groupChatId = ((sharedPreferences.get(CURRENT_ID).hashCode >
            widget.peer.data['id'].hashCode)
        ? (sharedPreferences.get(CURRENT_ID).hashCode -
                widget.peer.data['id'].hashCode)
            .toString()
        : (widget.peer.data['id'].hashCode -
                sharedPreferences.get(CURRENT_ID).hashCode)
            .toString());
  }
}
