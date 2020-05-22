import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


import 'package:shared_preferences/shared_preferences.dart';
import 'package:tas_murah/main.dart';
import 'package:tas_murah/model/api.dart';
import 'package:tas_murah/page/edit_profil.dart';
import 'package:tas_murah/page/pengaturan.dart';
import 'package:tas_murah/page/upload_img_profil.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();

}
enum LoginStatus { notSignIn, signIn }
class _ProfileState extends State<Profile> {
 LoginStatus _loginStatus = LoginStatus.notSignIn;
  var loading = false;
  String iduserx = "",selectedRadio="";

  TextEditingController txtnama = TextEditingController();
  TextEditingController txtemail = TextEditingController();
  TextEditingController txtalamat = TextEditingController();
  TextEditingController txtpass= TextEditingController();
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      iduserx = preferences.getString("iduser");
      ambildata();
    });
  }

  String email = "",
      nama = "",
      jk = "",
      photo = "",
      tgllahir= "",
      alamat = "";

  ambildata() async {
    loading = true;
    final response = await http.post(BaseUrl.getprofile,
        body: {"userx": iduserx,});
    final data = jsonDecode(response.body);
      setState(() {
        email = data['email'];
        txtnama.text = data['nama'];
        jk = data['jk'];
        photo = BaseUrl.lok_gb+""+data['photo'];
        tgllahir = data['tgl_lahir'];
        txtalamat.text = data['alamat'];
        loading = false;
        setSelectedRadio("$jk");
      });
      _reambildata();
  }

  void _reambildata() async {
    final response = await http.post(BaseUrl.getprofile,
        body: {"userx": iduserx,});
    final data = jsonDecode(response.body);
    setState(() {
      email = data['email'];
      txtnama.text = data['nama'];
      jk = data['jk'];
      photo = BaseUrl.lok_gb+""+data['photo'];
      tgllahir = data['tgl_lahir'];
      txtalamat.text = data['alamat'];
      loading = false;
      setSelectedRadio("$jk");
    });
    Future.delayed(Duration(seconds: 10)).then((_) {
      _reambildata();
    });
  }



  setSelectedRadio(String val) {
    setState(() {
      selectedRadio = val;
    });
  }

void keluar() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", null);
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn; 
       Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (BuildContext context) => Login()));
    });
}


  @override
  void initState() {
    super.initState();
    getPref();

  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 10),
              width: 200.0,
              height: 200.0,
              alignment: Alignment.bottomCenter,
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.fill, image: new NetworkImage("$photo"))),
              child: FlatButton.icon(
                color: Color.fromRGBO(255, 255, 255, 0.7),
                icon: Icon(Icons.camera_alt), //`Icon` to display
                label: Text("Change"), //`Text` to display
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UploadImageProfile()));
                },
              )
            ),
            new Divider(),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: FlatButton.icon(
                      color: Colors.green,
                      textColor: Colors.white,
                      icon: Icon(Icons.settings),
                      label: Text("Pengaturan"),
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => Pengaturan()));
                      },
                      shape: RoundedRectangleBorder(side: BorderSide(
                          color: Colors.white30,
                          width: 3,
                          style: BorderStyle.solid
                      ), borderRadius: BorderRadius.circular(15)),

                    ),

                    trailing: FlatButton.icon(
                        color: Colors.green,
                        textColor: Colors.white,
                        icon: Icon(Icons.edit), //`Icon` to display
                        label: Text('Profile'), //`Text` to display
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => Edit_Profil()));
                        },
                      shape: RoundedRectangleBorder(side: BorderSide(
                          color: Colors.white30,
                          width: 3,
                          style: BorderStyle.solid
                      ), borderRadius: BorderRadius.circular(15)),

                        ),

                  ),
                  new Divider(),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("${txtnama.text.toString()}"),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text(email),
                  ),
                  ListTile(
                    leading: Icon(Icons.star),
                    title: Text(tgllahir),
                  ),
                  ListTile(
                    leading: Icon(Icons.accessibility),
                    title: Text("$jk"),
                  ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text("${txtalamat.text.toString()}"),
                  ),
                  new Divider(),
                  ListTile(
                    title:  FlatButton.icon(
                        color: Colors.green,
                        textColor: Colors.white,
                        icon: Icon(Icons.exit_to_app), //`Icon` to display
                        label: Text('Keluar'), //`Text` to display
                        onPressed: () {
                         showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: new Text("Konfirmasi"),
                                content: new Text("Yakin ingin keluar.?"),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new FlatButton(
                                    child: new Text("Batal"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  new FlatButton(
                                    child: new Text("Ya"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      keluar();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      shape: RoundedRectangleBorder(side: BorderSide(
                          color: Colors.white30,
                          width: 3,
                          style: BorderStyle.solid
                      ), borderRadius: BorderRadius.circular(15)),

                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
