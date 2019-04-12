import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
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
    // facebook sign in
    var facebookLogin = new FacebookLogin();
    return facebookLogin.logInWithReadPermissions(['email', 'public_profile']).then((result) {
        switch (result.status) {
          case FacebookLoginStatus.loggedIn:
            final AuthCredential credential = FacebookAuthProvider.getCredential(
                accessToken: result.accessToken.token
            );
            _auth.signInWithCredential(credential).then((signedInUser) {
              print('Signed in as ${signedInUser.displayName}');
              // Navigator.of(context).pushReplacementNamed('/homepage');
              return signedInUser;
            }).catchError((e) {
              print(e);
              return null;
            });
            break;
          case FacebookLoginStatus.cancelledByUser:
            print('Cancelled by you');
            return null;
          case FacebookLoginStatus.error:
            print('Error');
            return null;
        }
    }).catchError((e) {
        print(e);
        return null;
    });
  }

  Future<void> _logOut() async {
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
        ) : 
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 40.0, 20.0, 30.0),
              child: new Container(
                child: RaisedButton(
                  onPressed: _logIn,
                  child: const Text('Facebook login', 
                        style: TextStyle(color: Colors.blue, fontSize: 40, 
                        fontWeight: FontWeight.bold),),
                ),
              ),
            )
          ],
        )//FacebookSignInButton(onPressed: _logIn),
      ),
    );
  }
}