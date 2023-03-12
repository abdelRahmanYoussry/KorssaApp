import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:foodpanda_users_app/global/global.dart';
import 'package:foodpanda_users_app/mainScreens/home_screen.dart';
import 'package:foodpanda_users_app/widgets/custom_text_field.dart';
import 'package:foodpanda_users_app/widgets/error_dialog.dart';
import 'package:foodpanda_users_app/widgets/loading_dialog.dart';

import 'auth_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;
  bool _checking = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkIfisLoggedIn();
  }

  _checkIfisLoggedIn() async {
    final accessToken = await FacebookAuth.instance.accessToken;

    setState(() {
      _checking = false;
    });

    if (accessToken != null) {
      print(accessToken.toJson());
      final userData = await FacebookAuth.instance.getUserData();
      _accessToken = accessToken;
      setState(() {
        _userData = userData;
      });
    } else {
      _login();
    }
  }

  _login() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;

      final userData = await FacebookAuth.instance.getUserData();
      _userData = userData;
    } else {
      print(result.status);
      print(result.message);
    }
    setState(() {
      _checking = false;
    });
  }

  _logout() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
    setState(() {});
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  formValidation() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      //login
      loginNow();
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please write email/password.",
            );
          });
    }
  }

  loginNow() async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingDialog(
            message: "Checking Credentials",
          );
        });

    User? currentUser;
    await firebaseAuth
        .signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user!;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });
    if (currentUser != null) {
      readDataAndSetDataLocally(currentUser!);
    }
  }

  Future<void> loginWithFacebook() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userData!['uid'])
        .set(_userData!)
        .then((value) {
      print('ZEYAD');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    userData: _userData!,
                  )));
    }).catchError((error) {
      print(error.toString());
    });
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        await sharedPreferences!.setString("uid", currentUser.uid);
        await sharedPreferences!.setString("email", snapshot.data()!["email"]);
        await sharedPreferences!.setString("name", snapshot.data()!["name"]);
        await sharedPreferences!
            .setString("photoUrl", snapshot.data()!["photoUrl"]);

        List<String> userCartList = snapshot.data()!["userCart"].cast<String>();
        await sharedPreferences!.setStringList("userCart", userCartList);

        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => HomeScreen(
                      userData: _userData!,
                    )));
      } else {
        firebaseAuth.signOut();
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const AuthScreen()));

        showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: "No record found.",
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Image.asset(
                "images/login.png",
                height: 270,
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.email,
                  controller: emailController,
                  hintText: "Email",
                  isObsecre: false,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: passwordController,
                  hintText: "Password",
                  isObsecre: true,
                ),
              ],
            ),
          ),
          ElevatedButton(
            child: const Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.cyan,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            ),
            onPressed: () {
              formValidation();
            },
          ),
          const SizedBox(
            height: 10,
          ),
          // _checking
          //     ? Center(
          //         child: CircularProgressIndicator(),
          //       )
          //     : Center(
          //         child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           _userData != null
          //               ? Text('name: ${_userData!['name']}')
          //               : Container(),
          //           _userData != null
          //               ? Text('email: ${_userData!['email']}')
          //               : Container(),
          //           _userData != null
          //               ? Container(
          //                   child: Image.network(
          //                       _userData!['picture']['data']['url']),
          //                 )
          //               : Container(),
          //           SizedBox(
          //             height: 20,
          //           ),
          //           CupertinoButton(
          //             color: Colors.blue,
          //             child: Text(
          //               _userData != null ? 'LOGOUT' : 'LOGIN',
          //               style: TextStyle(color: Colors.white),
          //             ),
          //             onPressed: () {
          //               if (_userData != null) {
          //                 print(_userData);
          //                 loginWithFacebook();
          //               } else {
          //                 _logout();
          //               }
          //             },
          //           )
          //         ],
          //       )),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.cyan,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            ),
            onPressed: () {
              loginWithFacebook().then((value) {
                sharedPreferences!.setString(
                    'photoUrl', _userData!['picture']['data']['url']);
                sharedPreferences!.setString('name', _userData!['name']);
                sharedPreferences!.setString('email', _userData!['email']);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen(userData: _userData!)));
              });

              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) =>
              //             WelcomeScreen(userData: _userData!)));
            },
            child: const Text(
              "Login With FaceBook",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
