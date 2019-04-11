import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: MyMainPage(),
  ));
}

class MyMainPage extends StatefulWidget {
  @override
  _MyMainPageState createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLogged = false;
  FirebaseUser myUser;

  Future<FirebaseUser> _loginWithFacebook() async {
    var facebookLogin = new FacebookLogin();
    var result = await facebookLogin.logInWithReadPermissions(["public_profile","email",]);

    // final token = result.accessToken.token;
    // final graphResponse = await http.get(
    //         'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
    // final profile = graphResponse.body.toString();
    // // debugPrint(result.status.toString());
    // debugPrint(profile);

    final AuthCredential credential = FacebookAuthProvider.getCredential(
      accessToken: result.accessToken.token
    );

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FirebaseUser user = await _auth.signInWithCredential(credential);
        return user;
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Cancel by user');
        break;
      case FacebookLoginStatus.error:
        print('Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
      default:
        return null;
    }
  }

  void _logOut() async {
    await _auth.signOut().then((response) {
      isLogged = false;
      setState(() { });
    });
  }

  void _logIn() {
     _loginWithFacebook().then((response) {
      if(response != null) {
        myUser = response;
        isLogged = true;
        setState(() { });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text(isLogged ? "Profile Page" : "Faceboook Login App"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.power_settings_new),
            onPressed: _logOut,
          )
        ],
      ),
      body: Center(
        child: isLogged ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Name: "+ myUser.displayName),
            Image.network(myUser.photoUrl),
          ],
        ) : FacebookSignInButton(onPressed: _logIn),
      ),
    );
  }
}