import 'package:chat_app_flutter/Resources/auth_methods.dart';
import 'package:chat_app_flutter/Screens/ChattingScreen/chatting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Login/login_screen.dart';

//Below is not the Home Screen which consists of widgets.
//it's a stateful widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  //Some variables to define and be used in the project.
  final TextEditingController _searchController = TextEditingController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late CollectionReference usersRef = firebaseFirestore.collection("users");
  Map<String, dynamic>? userMap;

  //Initialize before the page starts.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
  }

  //a method to set the status of the user Online or Offline.
  void setStatus(String status) async {
    await firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({
      "status": status,
    });
  }

  //a method to determine the lifeCycle of the app that in what state it is.
  //is it running on the background or shutdown etc.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else if (state == AppLifecycleState.detached) {
      setStatus("Offline");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  // A method to find out the user on the based of organization email address
  void searchUser() async {
    await firebaseFirestore
        .collection("users")
        .where("email", isEqualTo: _searchController.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        print(userMap);
      });
    });
  }

  //A method to store the ID of the chat between the parties involved for a chat.
  String chatRoomId(String user1, String user2) {
    print("inside chatroom");
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  // A whole widget tree that shows the interface of the Home Screen
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Chats"),
              InkWell(
                onTap: () async {
                  await AuthMethods().loginOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LogInScreen();
                      },
                    ),
                  );
                },
                child: Icon(Icons.logout),
              ),
            ],
          ),
          backgroundColor: Colors.green[800],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  width: size.width - 90,
                  height: size.height * 0.01,
                ),
                RoundedInputField(
                  textEditingController: _searchController,
                  hintText: 'Search by email',
                  icon: Icons.search,
                  onChanged: (String value) {},
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 150, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green[800],
                        //padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        textStyle: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      searchUser();
                    },
                    child: Text(
                      "Search".toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                userMap?.isEmpty == false
                    ? ListTile(
                        onTap: () {
                          print("just before the chatRoomId");
                          String roomId = chatRoomId(
                              AuthMethods().giveUserName() as String,
                              userMap!['name']);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatRoomId: roomId,
                                userMap: userMap!,
                              ),
                            ),
                          );
                        },
                        leading: Icon(Icons.account_box, color: Colors.black),
                        title: Text(
                          userMap!['name'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(userMap!['email']),
                        trailing: Icon(Icons.chat, color: Colors.black),
                      )
                    : Container(),
              ],
            ),
          ),
        ));
  }
}

// Made re use able widgets for Input fields.
//Just for the designing purposes.
class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController textEditingController;

  const RoundedInputField({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.onChanged,
    required this.textEditingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        controller: textEditingController,
        onChanged: onChanged,
        decoration: InputDecoration(
            icon: Icon(
              icon,
              color: Colors.black,
            ),
            fillColor: Colors.white,
            hintText: hintText),
      ),
    );
  }
}


// Made re use able widgets for Input fields.
//Just for the designing purposes.
class TextFieldContainer extends StatelessWidget {
  final Widget child;

  const TextFieldContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      //height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(29),
      ),
      child: child,
    );
  }
}
