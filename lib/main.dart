import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tas_murah/page/keranjang.dart';
import 'package:tas_murah/page/notifikasi.dart';
import 'package:tas_murah/page/pencarian.dart';
import 'package:tas_murah/tab/home.dart';
import 'package:tas_murah/tab/hometwo.dart';

import 'model/api.dart';
import 'tab/profile.dart';
import 'tab/promo.dart';
import 'tab/transaksi.dart';


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Intro Layout',
    home: Login(),
  ));
}
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String username, password;
  final _key = new GlobalKey<FormState>();
  bool _secureText = true;
  var loading = false;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      login();
    }
  }

  login() async {
    setState(() {
      loading = true;
    });
    final response = await http.post(BaseUrl.login,
        body: {"username": username, "password": password});
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    String usernameAPI = data['username'];
    String namaAPI = data['nama'];
    String id = data['iduser'];
    if (value == 1) {
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(value, usernameAPI, namaAPI, id);
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Login"),
            content: new Text(pesan),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  savePref(int value, String username, String nama, String id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.setString("nama", nama);
      preferences.setString("username", username);
      preferences.setString("iduser", id);
      preferences.commit();
    });
  }

  var value;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");

      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", null);
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          backgroundColor: Colors.green,
//          appBar: AppBar(
//            backgroundColor: Colors.lightBlueAccent,
//            title:Center(
//              child: Text("Login"),
//            )
//          ),
          body: Form(
            key: _key,
            child: ListView(
              padding: EdgeInsets.only(top: 76.0, left: 26.0, right: 26.0),
              children: <Widget>[
                Image.asset(
                  "pendukung/logotas.png",
                  height: 150.0,
                  width: 150.0,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 20),
                ),
                TextFormField(
                  validator: (e) {
                    if (e.isEmpty) {
                      return "Please insert email";
                    } else if (!e.contains(EmailValidator.regex)) {
                      return "Email not valid";
                    }
                  },
                  onSaved: (e) => username = e,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                        onPressed: showHide, icon: Icon(Icons.person)),
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                TextFormField(
                  obscureText: _secureText,
                  onSaved: (e) => password = e,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Password",
                    suffixIcon: IconButton(
                      onPressed: showHide,
                      icon: Icon(_secureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                  ),
                ),
                loading
                    ? Center(
                  child: CircularProgressIndicator(),
                )
                    : MaterialButton(
                    color: Colors.white,
                    onPressed: () {
                      check();
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0))),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Register()));
                  },
                  child: Text(
                    "Create a new account, in here",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      case LoginStatus.signIn:
        return MainMenu(signOut);
        break;
    }
  }
}

class EmailValidator {
  static final RegExp regex = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
}

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String username, password, nama_depan, nama_belakang, selectedRadio;
  var loading = false;
  final _key = new GlobalKey<FormState>();

  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      save();
    }
  }

  save() async {
    setState(() {
      loading = true;
    });
    final response = await http.post(BaseUrl.register, body: {
      "nama": nama_depan,
      "username": username,
      "password": password,
      "jk": selectedRadio
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    if (value == 1) {
      setState(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Register"),
              content: new Text(pesan),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Register"),
              content: new Text(pesan),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  setSelectedRadio(String val) {
    setState(() {
      selectedRadio = val;
    });
  }

  initState() {
    super.initState();
    setSelectedRadio("Pria");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
//      appBar: AppBar(
//        backgroundColor: Colors.lightBlueAccent,
//        title: Center(
//         child: Text("Register"),
//        )
//      ),
      body: Form(
        key: _key,
        child: ListView(
          padding:
          EdgeInsets.only(top: 76.0, left: 26.0, right: 26.0, bottom: 26.0),
          children: <Widget>[
            Image.asset(
              "pendukung/logotas.png",
              height: 150,
              width: 150,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
            ),
            TextFormField(
              validator: (e) {
                if (e.isEmpty) {
                  return "Please insert first name";
                }
              },
              onSaved: (e) => nama_depan = e,
              decoration: new InputDecoration(
                filled: true,
                labelText: "First Name",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(),
                ),
                //fillColor: Colors.green
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
            ),

            Padding(
              padding: EdgeInsets.only(top: 10),
            ),
            TextFormField(
              decoration: new InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(),
                ),
                //fillColor: Colors.green
              ),
              validator: (e) {
                if (e.isEmpty) {
                  return "Please insert email";
                } else if (!e.contains(EmailValidator.regex)) {
                  return "Email not valid";
                }
              },
              onSaved: (e) => username = e,
              keyboardType: TextInputType.emailAddress,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
            ),
            TextFormField(
              validator: (e) {
                if (e.isEmpty) {
                  return "Please insert password";
                } else if (e.length < 4) {
                  return "Password must more than 4 characters";
                }
              },
              obscureText: _secureText,
              onSaved: (e) => password = e,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(),
                ),
                labelText: "Password",
                suffixIcon: IconButton(
                  onPressed: showHide,
                  icon: Icon(
                      _secureText ? Icons.visibility_off : Icons.visibility),
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                Radio(
                  value: "Pria",
                  groupValue: selectedRadio,
                  activeColor: Colors.white,
                  onChanged: (val) {
                    setSelectedRadio(val);
                  },
                ),
                Text(
                  "Pria",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Radio(
                  value: "Wanita",
                  groupValue: selectedRadio,
                  activeColor: Colors.white,
                  onChanged: (val) {
                    setSelectedRadio(val);
                  },
                ),
                Text(
                  "Wanita",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            loading
                ? Center(
              child: CircularProgressIndicator(),
            )
                : MaterialButton(
                color: Colors.white,
                onPressed: () {
                  check();
                },
                child: Text("Register"),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)))
          ],
        ),
      ),
    );
  }
}

class MainMenu extends StatefulWidget {
  final VoidCallback signOut;

  MainMenu(this.signOut);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  String username = "",
      nama = "",
      idprox = "",
      fotox = "";
      int Jp=0;
      int Jker=0;

  TabController tabController;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      username = preferences.getString("username");
      nama = preferences.getString("nama");
      idprox = preferences.getString("iduser");
      _ambildata();
    });
  }
//
 void _ambildata() async {
    final response =await http.post(BaseUrl.getnotic, body: {"iduser": idprox});
    final data = jsonDecode(response.body);
    int valueBB = data['value'];
    if (valueBB == 1) {
      setState(() {
        Jp = int.parse(data['jnotif']);
        Jker = int.parse(data['jcart']);
      });
    }
    Future.delayed(Duration(seconds: 10)).then((_) {
      _ambildata();
    });
  }
  updateToken(dtoken) async {
    final response = await http.post(BaseUrl.updateToken, body: {"iduser": idprox,"token":dtoken});
    final data = jsonDecode(response.body);
  }

void dispose(){
    super.dispose();
}
  final FirebaseMessaging firemessaging = new  FirebaseMessaging();
  @override
  void initState() {
    super.initState();

    firemessaging.subscribeToTopic("semua");
    firemessaging.configure(
      onMessage: (Map<String, dynamic> message) async{
       _ambildata();
      },
      onLaunch: (Map<String, dynamic> message) async{
        _ambildata();
      },
      onResume: (Map<String, dynamic> message) async{
        String rk = message['data']['status'];
        if(rk=='notif'){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Notifikasi()),
          );
        }else{
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Notifikasi()),
          );
        }
      },
    );

    firemessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true,
          alert: true,
          badge: true
      ),
    );

    firemessaging.onIosSettingsRegistered.listen((IosNotificationSettings setting){
    });
    firemessaging.getToken().then((token){
      updateToken(token);
    });
getPref();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {


    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("TMK", style: TextStyle(fontWeight: FontWeight.bold),),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Pencarian()));
              },
              icon: Icon(Icons.search, color: Colors.white,),
            ),
            new Stack(
              children: <Widget>[
                new IconButton(icon: Icon(Icons.notifications), onPressed: () {
//                  pindah halaman ke halaman notifikasi
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Notifikasi()));
                }),
                Jp != 0 ? new Positioned(
                  right: 11,
                  top: 11,
                  child: new Container(
                    padding: EdgeInsets.all(2),
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$Jp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ) : new Container()
              ],
            ),

            new Stack(
              children: <Widget>[
                new IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Keranjang()));
                }),
                Jker != 0 ? new Positioned(
                  right: 11,
                  top: 11,
                  child: new Container(
                    padding: EdgeInsets.all(2),
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${Jker}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ) : new Container()
              ],
            ),
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            HomeT(),
            Promo(),
            Transaksi(),
            Profile()
          ],
        ),
        bottomNavigationBar: TabBar(
          labelColor: Colors.red,
          unselectedLabelColor: Colors.green,
          indicator: UnderlineTabIndicator(
              borderSide: BorderSide(style: BorderStyle.solid)),
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.home),
              text: "Home",
            ),
            Tab(
              icon: Icon(Icons.fiber_new),
              text: "Promo",
            ),
            Tab(
              icon: Icon(Icons.category),
              text: "Transaksi",
            ),
            Tab(
              icon: Icon(Icons.people),
              text: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
