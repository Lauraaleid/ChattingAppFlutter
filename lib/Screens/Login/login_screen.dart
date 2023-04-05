import 'package:flutter/material.dart';

import '../../Components/already_have_an_account.dart';
import '../../Resources/auth_methods.dart';
import '../Home/home_screen.dart';
import '../SignUp/signup_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  late bool _obsecureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: size.width - 90,
              height: size.height * 0.4,
              // child: SvgPicture.asset(
              //   "assets/icons/signup.svg",
              //   // height: size.height * 0.45,
              //   //width: 50,
              // ),
            ),
            RoundedInputField(
              textEditingController: _emailController,
              hintText: 'Email',
              icon: Icons.person,
              onChanged: (String value) {},
            ),
            TextFieldContainer(
              child: TextField(
                controller: _passwordController,
                obscureText: _obsecureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  fillColor: Colors.white,
                  icon: Icon(
                    Icons.lock,
                    color: Colors.black,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_obsecureText) {
                          _obsecureText = false;
                        } else {
                          _obsecureText = true;
                        }
                      });
                    },
                    child: Icon(
                      _obsecureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black,
                    ),
                  ),
                  //border: InputBorder.none
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.greenAccent[400],
                    //padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  String res = await AuthMethods().loginUser(
                      email: _emailController.text,
                      password: _passwordController.text);
                  if (res == "Success") {
                    ClearFields();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return HomeScreen();
                        },
                      ),
                    );
                  } else {
                    final snackBar = SnackBar(
                      content: const Text('User Not Found!'),
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {
                          // Some code to undo the change.
                        },
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Text(
                  "Login".toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            //Below is the class that is determined to check whether the user already have an account or wants to sign up
            //it also consists a return type of widget
            AlreadyHaveAnAccountCheck(
              login: true,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen();
                    },
                  ),
                );
              },
            ),
            SizedBox(
              height: 50,
            ), //For Allignment of Layout
          ],
        ),
      ),
    );
  }

  //A function to clear fields for the better user experience.
  void ClearFields() {
    _emailController.text = "";
    _passwordController.text = "";
  }
}

// a widget for the design purposes in the LogIn Screen
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
            fillColor: Colors.white70,
            hintText: hintText),
      ),
    );
  }
}

// a widget for the design purposes in the LogIn Screen
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
          border: Border.all(
            color: Colors.grey,
            width: 2.0,
          ),
      ),
      child: child,
    );
  }
}
