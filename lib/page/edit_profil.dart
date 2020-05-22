import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tas_murah/model/api.dart';

class Edit_Profil extends StatefulWidget {
  @override
  _EditProfilState createState() => _EditProfilState();
}

class _EditProfilState extends State<Edit_Profil> {
  String iduserx = "",selectedRadio="";
  var loading = false;
  String email = "",
      nama = "",
      jk = "",
      photo = "",
      alamat = "";
  DateTime dateTime;
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

  @override
  void initState() {
    super.initState();
    getPref();

  }
  ambildata() async {
    loading = true;
    final response = await http.post(BaseUrl.getprofile,
        body: {"userx": iduserx,});
    final data = jsonDecode(response.body);
    print(data);
    setState(() {
      txtnama.text = data['nama'];
      jk = data['jk'];
      photo = BaseUrl.lok_gb+""+data['photo'];
      txtalamat.text = data['alamat'];
      _date = data['tgl_lahir'];
      loading = false;
      dateTime = DateTime.parse(_date);
      setSelectedRadio("$jk");
    });
  }
  setSelectedRadio(String val) {
    setState(() {
      selectedRadio = val;
    });
  }
  String _date = "Belum Diatur";
  _setDate(){
    Navigator.of(context).pop();
  }


  updateProfile() async{
    setState(() {
      loading= true;
    });

    final responsex = await http.post(BaseUrl.ubah_profile,
        body: {"user": iduserx, "nama": txtnama.text, "jk": selectedRadio,
          "pass": txtpass.text,"alamat":txtalamat.text, "tgl_lahir":_date
        });
    final datax = jsonDecode(responsex.body);
    setState(() {
      loading= false;
    });
    await new Future.delayed(const Duration(seconds: 3));
    ambildata();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            "Edit Profil",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,

        ),
        body: loading
            ? Center(child: CircularProgressIndicator()): Container(
          padding: EdgeInsets.all(15),
         child: SingleChildScrollView(
        child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
        new TextField(
        decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: "Nama..",
        border:
        new OutlineInputBorder(
        borderRadius:
        new BorderRadius
            .circular(10.0),
        borderSide:
        new BorderSide(),
        ),
        ),
        maxLength: 15,
        onSubmitted: null,
        controller: txtnama,
        ),
        ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
        Radio(
        value: "Pria",
        groupValue: selectedRadio,
        activeColor: Colors.black,
        onChanged: (val) {
        setSelectedRadio(val);
        },
        ),
        Text('Pria'),
        Radio(
        value: "Wanita",
        groupValue: selectedRadio,
        activeColor: Colors.black,
        onChanged: (val) {
        setSelectedRadio(val);
        },
        ),
        Text('Wanita'),
        ],
        ),
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            elevation: 4.0,
            onPressed: () {
              DatePicker.showDatePicker(context,
                  theme: DatePickerTheme(
                    containerHeight: 210.0,
                  ),
                  showTitleActions: true,
                  minTime: DateTime(1980, 1, 1),
                  maxTime: DateTime(2012, 12, 31), onConfirm: (date) {
                    print('confirm $date');
                    _date = '${date.year}-${date.month}-${date.day}';
                    setState(() {});
                  },
                  currentTime: dateTime, locale: LocaleType.en);
            },
            child: Container(
              alignment: Alignment.center,
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Tanggal Lahir",
                    style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.date_range,
                              size: 18.0,
                              color: Colors.teal,
                            ),
                            Text(
                              " $_date",
                              style: TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                ],
              ),
            ),
            color: Colors.white,
          ),
          SizedBox(
            height: 20.0,
          ),
        Padding(
        padding: EdgeInsets.only(
        top: 10),
        ),
        new TextField(
        maxLines: 4,
        maxLength: 200,
        keyboardType:TextInputType.multiline,
        decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: "Alamat",
        border:
        new OutlineInputBorder(
        borderRadius:
        new BorderRadius
            .circular(10.0),
        borderSide:
        new BorderSide(),
        ),
        ),
        textInputAction:TextInputAction.newline,
        onSubmitted: null,
        controller: txtalamat,
        ),
        Padding(
        padding: EdgeInsets.only(
        top: 10),
        ),
        new TextField(
        decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: "Password",
        border:
        new OutlineInputBorder(
        borderRadius:
        new BorderRadius
            .circular(10.0),
        borderSide:
        new BorderSide(),
        ),
        ),
        maxLength: 15,
        onSubmitted: null,
        controller: txtpass,
        ),
          Padding(
            padding: EdgeInsets.only(top: 25),
          ),
          FlatButton.icon(onPressed: (){
            updateProfile();
          }, icon: Icon(Icons.save, color: Colors.white,),
            label:Text('                Simpan                          ', style: TextStyle(color: Colors.white),), color: Colors.green,),

        ],
        ),
    )
        )
        );
        }

}
