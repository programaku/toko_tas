import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Pengaturan extends StatefulWidget {
  @override
  _PengaturanState createState() => _PengaturanState();
}


class _PengaturanState extends State<Pengaturan> {
  bool isSwitched= true;
  final FirebaseMessaging firemessaging = new  FirebaseMessaging();
  String sts_notif_channel ="";

  getSesi() async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      sts_notif_channel = preferences.getString("stsnotif");
      print(sts_notif_channel);

      if(sts_notif_channel=="false"){
          isSwitched =false;
      }else{
          isSwitched = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getSesi();

  }
  saveSesi(String sts) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setString("stsnotif", sts);
      preferences.commit();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "Pengaturan",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
        body:Container(
        child: Column(
        children: <Widget>[
          ListTile(
            leading: Text('Notifikasi Promo'),
            trailing: Switch(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                  saveSesi("$value");
                  if(value=="false"){
                    firemessaging.unsubscribeFromTopic("semua");
                  }else{
                    firemessaging.subscribeToTopic("semua");
                  }

                });
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            ),
          ),
        ],
      )
      ),
    );
  }
}

