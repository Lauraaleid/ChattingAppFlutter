import 'dart:io';

import 'package:chat_app_flutter/Resources/my_encryption_decryption.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatScreen({required this.chatRoomId, required this.userMap});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //Some Variables to be defined and used in the app.
  final TextEditingController _message = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //A variable to store the picked files.
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  late String textToCopy;

  //A future method to store the message in firebase
  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      //Below is the function called from another file to encrypt the data.
      String messageEncrypted = MyEncryptionDecryption()
          .encryptStringAES(_message.text, "MySecretPassword");

      //a map of messages is formed then it is stored in the data base.
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": messageEncrypted,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      //To clear out the field where the message is typed.
      _message.clear();

      //Below is the Query to add the message in the database
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print("Enter Some Text");
    }
  }

  //a future function to select a file from the gallery and then assigning to the picked file
  Future onPickFile() async {
    final file = await FilePicker.platform.pickFiles();
    if (file == null)
      return null;
    else {
      setState(() {
        pickedFile = file.files.first;
      });
    }
  }

  //A function to upload a file in firebase storage
  Future onUploadFile() async {
    try {
      final path = 'files/${pickedFile?.name}';
      final file2 = File(pickedFile!.path!);
      print("hi after the file is picked");
      final ref = FirebaseStorage.instance.ref().child(path);
      uploadTask = ref.putFile(file2);
      print("hi after the file is uploaded");

      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      setState(() {
        _message.text = urlDownload;
      });
    } on FirebaseException catch (e) {
      print(e.toString());
      return null;
    }
  }

  //A whole widget tree that shows the interface of the chat screen.
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection("users")
              .doc(widget.userMap['uid'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Container(
                child: Column(
                  children: [
                    Text(widget.userMap['name']),
                    Text(
                      snapshot.data!['status'],
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chatroom')
                    .doc(widget.chatRoomId)
                    .collection('chats')
                    .orderBy("time", descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return Container(
                      padding: EdgeInsets.only(
                          top: 15.0, left: 16.0, bottom: 8.0, right: 16.0),
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          //getMapDecrypted(map);
                          // print(map['message']);
                          // print("break");
                          return messages(size, map, context);
                        },
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                height: 70.0,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 15,
                    ),
                    IconButton(
                      icon: Icon(Icons.attach_file),
                      iconSize: 25.0,
                      color: Colors.black,
                      onPressed: () {
                        onPickFile();
                        print(pickedFile?.name);
                        onUploadFile();
//                        onSendMessage();
                      },
                    ),
                    Expanded(
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: _message,
                        onChanged: (value) {},
                        decoration: InputDecoration.collapsed(
                          hintText: 'Send a message...',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      iconSize: 25.0,
                      color: Colors.grey,
                      onPressed: () {
                        onSendMessage();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //A whole widget tree that shows the messages of both the users in the form of map.
  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ? map['sendby'] == _auth.currentUser!.displayName
            //if the current user has send the message then display this
            ? Container(
                width: size.width,
                alignment: Alignment.centerRight, //Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        textToCopy = MyEncryptionDecryption().decryptStringAES(
                            map['message'], "MySecretPassword");
                      });
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Text copied to clipboard')));
                    },
                    child: Text(
                      //map['message'],
                      MyEncryptionDecryption()
                          .decryptStringAES(map['message'], "MySecretPassword"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )

            //else not the user then for the other user show the box with different decoration and color.
            : Container(
                width: size.width,
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.green[800],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        textToCopy = MyEncryptionDecryption().decryptStringAES(
                            map['message'], "MySecretPassword");
                      });
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Text copied to clipboard')));
                    },
                    child: Text(
                      //map['message'],
                      //Below is the function called for the Decryption
                      MyEncryptionDecryption()
                          .decryptStringAES(map['message'], "MySecretPassword"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
        : Container(
            // an empty container
            );
  }
}
