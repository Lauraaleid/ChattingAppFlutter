import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// now this file contains the class that has the Methods
// to call from firebase and use authentication methods.
// This will store the user in database and will help in LogIn and SignUp
class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User user;

  //Method for SignUp User or Register New User
  Future<String> signUpUser(
      {required String email, required String password, required String username}) async {
    String res = "Some Error Occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        //Below is the query that will Create the User in Authentication Tab.
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        res = "Success";

        //Below is the query that will Create the User in FireStore.
        await _firestore.collection("users").doc(_auth.currentUser?.uid).set({
          "name": username,
          "email": email,
          "status": "Unavailable",
          "uid": _auth.currentUser?.uid,
        });

        //Below is used to get the User Object to use it's Display name later in chat screen
        // or anywhere in the whole app.
        user =(await _auth.currentUser)!;
        user?.updateProfile(displayName: username);
        ;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //Method for LogIn User with it's email and password assign.
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some Error Occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //Method to give the Username of current LoggedIn user
  String? giveUserName(){
    return _auth.currentUser!.displayName;
  }

  //Method to give the Email of current LoggedIn user
  String? giveUserEmail(){
    return _auth.currentUser!.email;
  }

  //Method for LogOut User.
  Future<String> loginOut() async {
    String res = "Some Error Occured";
    try {
      await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
        "status": "Unavailable",
      });
      await _auth.signOut();

      res = "Success";
    }
    catch (err) {
      res = err.toString();
    }
    return res;
  }
}
