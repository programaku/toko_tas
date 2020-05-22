import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tas_murah/model/model_notifikasi.dart';
import 'package:tas_murah/page/detail_produk.dart';

import 'detail_transaksi.dart';

class Notifikasi extends StatefulWidget {
  @override
  _NotifikasiState createState() => _NotifikasiState();
}

class _NotifikasiState extends State<Notifikasi> {

  var btlist=false;
  var btsemua= false;
  var btpromo=false;

  String iduser ='0';
  var loading = false;
  List<Model_Notifikasi> _list =[];
String judul='', waktu='', pesan='';
  getPref()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      iduser = preferences.get("iduser");
    });
    fetchData('semua');
    gantiTombol('semua');
  }
  @override
  void initState() {
    super.initState();
    getPref();

  }

  @override
  void dispose(){
    super.dispose();
  }


  Future<Null> fetchData(md) async {
    setState(() {
      loading = true;
    });
    _list.clear();
    String xxx = "https://leonybuah.com/api/notifikasi.php?mode=$md&user=$iduser";
    final response = await http.get(xxx);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if(data.length == 0){
        setState(() {
          loading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  'Belum Ada Notifikasi..'
              ),
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
      }else {
        setState(() {
          for (Map i in data) {
            _list.add(Model_Notifikasi.dariJson(i));
            loading = false;
          }

        });

      }

    }

  }

  Future<Null> terbaca(idnotif) async {
    String xbaca = "https://leonybuah.com/api/notifikasi.php?mode=terbaca&idnotif=$idnotif";
    final response = await http.get(xbaca);
    int respon = response.statusCode;
    }

  void gantiTombol(bt) async{
    if(bt=="semua"){
      setState(() {
        btlist=false;
        btpromo=false;
        btsemua=true;
      });
    }else if(bt=="list" ){
      setState(() {
        btlist=true;
        btpromo=false;
        btsemua=false;
      });
    }else if(bt=="promo"){
      setState(() {
        btlist=false;
        btpromo=true;
        btsemua=false;
      });
    }
  }

  Future<Null>deleteItem(index,idnot) async{
    String xdel = "https://leonybuah.com/api/notifikasi.php?mode=hapus&idnotif=$idnot";
    final response = await http.get(xdel);
    setState((){
      _list.removeAt(index);
    });
  }

  void undoDeletion(index, item){
    setState((){
      _list.insert(index, item);
    });
  }


  List<Color> _colors = [
    Colors.white70,
    Colors.white
  ];
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            "Notifikasi",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body:  loading ? Center(child: CircularProgressIndicator(),) :  Container(

              child: Column(
              children: <Widget>[
             SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: new Row(
              children: <Widget>[
                FlatButton.icon(color: btsemua ? Colors.green : Colors.grey,
                  onPressed: (){
                    gantiTombol("semua");
                    fetchData("semua");
                  },
                  icon: Icon(Icons.hdr_strong,color: Colors.white ), label: Text("Semua", style: TextStyle(color: Colors.white),),
                  shape: RoundedRectangleBorder(side: BorderSide(
                      color: Colors.white30,
                      width: 3,
                      style: BorderStyle.solid
                  ), borderRadius: BorderRadius.circular(15)),
                ),

                Padding(
                  padding: EdgeInsets.all(5),
                ),
                FlatButton.icon(color:btlist ? Colors.green : Colors.grey,
                  onPressed: (){
                    gantiTombol("list");
                    fetchData("list");
                  },
                  icon: Icon(Icons.hourglass_empty, color: Colors.white ), label: Text("Transaksi", style: TextStyle(color: Colors.white),),
                  shape: RoundedRectangleBorder(side: BorderSide(
                      color: Colors.white30,
                      width: 3,
                      style: BorderStyle.solid
                  ), borderRadius: BorderRadius.circular(15)),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                FlatButton.icon(color: btpromo ? Colors.green : Colors.grey,
                  onPressed: (){
                    gantiTombol("promo");
                    fetchData("promo");
                  },
                  icon: Icon(Icons.money_off, color: Colors.white,), label: Text("Promo", style: TextStyle(color: Colors.white),),
                  shape: RoundedRectangleBorder(side: BorderSide(
                      color: Colors.white30,
                      width: 3,
                      style: BorderStyle.solid
                  ), borderRadius: BorderRadius.circular(15)),
                ),

              ],
            ),
          ),


                Expanded(
                  child:
                  ListView.builder(

                    itemCount: _list.length,
                    itemBuilder: (context, i){
                      final a = _list[i];
//                      int cekKeranjang = int.parse(a.keranjang);
                      String cekbaca = a.baca;
                      String xresi = a.resi;


                      return Dismissible(
                          key: ObjectKey(a.idnotifikasi),
                        background: stackBehindDismiss(),
                        onDismissed: (direction) {
                          var item = _list.elementAt(i);
                          //To delete
                          deleteItem(i, a.idnotifikasi);
                          //To show a snackbar with the UNDO button
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text("Notifikasi Terhapus.."),
//                              action: SnackBarAction(
//                                  label: "UNDO",
//                                  onPressed: () {
//                                    //To undo deletion
//                                    undoDeletion(i, item);
//                                  })
                          ));
                        },

                      child: GestureDetector(
                        onTap: (){
                          terbaca(a.idnotifikasi);
                          if(xresi =="AA"){
                            if(a.idbarang =='0'){

                            }else{
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (context) => Detail_Produk(kirimid: a.idbarang)));
                            }
                          }else{
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => Detail_Transaksi(kirimid: a.resi)));
                          }

                        },
                          child: Container(

                        padding: EdgeInsets.all(5.0),
                        child: Card(

                          color: cekbaca=='N' ? Colors.white : Colors.white60,
                          child: Column(
                            mainAxisSize: MainAxisSize.min, children: <Widget>[
                            ListTile(
                                title:
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                    ),
                                    Text("${a.judul}", style: TextStyle(fontWeight: FontWeight.bold,
                                        fontSize: 14.0, color: Colors.black),),
                                   Divider(),
                                    Text("${a.pesan}", style: TextStyle(
                                        fontSize: 14.0, color: Colors.black),),
//                                   Divider(),
                                    Text("${a.waktu}", style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 12),),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                    ),
                                  ],
                                )
//
                            ),

                          ],),
                        ),
                          )
                      )
                      );
                    },
                  ),
                ),

              ],
            )

    )
    );
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.white,
      child: Icon(
        Icons.delete,
        color: Colors.red,
        size: 50.0,
      ),
    );
  }
}
