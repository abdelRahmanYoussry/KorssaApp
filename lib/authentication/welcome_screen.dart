import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({Key? key, required this.userData}) : super(key: key);
  final Map<String, dynamic> userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Welcome Screen'),
      ),
      body: Column(
        children: [
          userData != null ? Text('name: ${userData['name']}') : Container(),
          userData != null ? Text('email: ${userData['email']}') : Container(),
          userData != null
              ? Container(
                  child: Image.network(userData['picture']['data']['url']),
                )
              : Container(),
          const SizedBox(
            height: 20,
          ),
          CupertinoButton(
            color: Colors.blue,
            child: Text(
              userData != null ? 'LOGOUT' : 'LOGIN',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (userData != null) {
                print(userData);
                // loginWithFacebook();
              } else {
                // _logout();
              }
            },
          )
        ],
      ),
    );
  }
}
