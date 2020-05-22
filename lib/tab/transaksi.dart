import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tas_murah/model/model_transaksi.dart';
import 'package:tas_murah/page/detail_transaksi.dart';


class Transaksi extends StatefulWidget {
  @override
  _TransaksiState createState() => _TransaksiState();
}

class _TransaksiState extends State<Transaksi> {
  String iduser ='0';
  var loading = false;
  var loading2 = false;

  var btditerim=false;
  var btsemua= false;
  var btblmbayar=false;
  var btsdhbayar= false;
  List<Model_Transaksi> _list =[];


  getPref()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      iduser = preferences.get("iduser");
    });
    fetchData("list");
  }
  @override
  void initState() {
    super.initState();
    getPref();
    gantiTombol("semua");
  }

  @override
  void dispose(){
    super.dispose();
  }

  void gantiTombol(bt) async{
    if(bt=="semua"){
      setState(() {
        btditerim=false;
        btsdhbayar=false;
        btblmbayar=false;
        btsemua=true;
      });
    }else if(bt=="blm" ){
      setState(() {
        btditerim=false;
        btsdhbayar=false;
        btblmbayar=true;
        btsemua=false;
      });
    }else if(bt=="sdh"){
      setState(() {
        btditerim=false;
        btsdhbayar=true;
        btblmbayar=false;
        btsemua=false;
      });
    }else if(bt=="diterima"){
      setState(() {
        btditerim=true;
        btsdhbayar=false;
        btblmbayar=false;
        btsemua=false;
      });
    }
  }

  Future<Null> fetchData(mode) async {
    setState(() {
      loading = true;
    });
    _list.clear();
    String xxx = "https://leonybuah.com/api/transaksi.php?mode=$mode&user=$iduser";
    final response = await http.get(xxx);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if(data.length == 0){
        setState(() {
          loading = false;
          loading2 = true;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  'Transaksi Kosong..'
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
            _list.add(Model_Transaksi.dariJson(i));
            loading = false;
            loading2=false;
          }
        });

      }

    }else{
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Masalah Jaringan..'),
        duration: Duration(seconds: 3),
      ));
      setState(() {
        loading= false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title:
          new SingleChildScrollView(
          scrollDirection: Axis.horizontal,
            child: new Row(
              children: <Widget>[
                FlatButton.icon(color: btsemua ? Colors.green : Colors.grey,
                  onPressed: (){
                  gantiTombol("semua");
                  fetchData("list");
                  },
                  icon: Icon(Icons.all_inclusive,color: Colors.white ), label: Text("Semua", style: TextStyle(color: Colors.white),),
                  shape: RoundedRectangleBorder(side: BorderSide(
                      color: Colors.white30,
                      width: 3,
                      style: BorderStyle.solid
                  ), borderRadius: BorderRadius.circular(15)),
                ),

                Padding(
                  padding: EdgeInsets.all(5),
                ),
                FlatButton.icon(color:btblmbayar ? Colors.green : Colors.grey,
                  onPressed: (){
                  gantiTombol("blm");
                  fetchData("blm");
                  },
                  icon: Icon(Icons.money_off, color: Colors.white ), label: Text("Belum Bayar", style: TextStyle(color: Colors.white),),
                  shape: RoundedRectangleBorder(side: BorderSide(
                      color: Colors.white30,
                      width: 3,
                      style: BorderStyle.solid
                  ), borderRadius: BorderRadius.circular(15)),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                FlatButton.icon(color: btsdhbayar ? Colors.green : Colors.grey,
                  onPressed: (){
                  gantiTombol("sdh");
                  fetchData("sdh");
                  },
                  icon: Icon(Icons.money_off, color: Colors.white,), label: Text("Sudah Bayar", style: TextStyle(color: Colors.white),),
                  shape: RoundedRectangleBorder(side: BorderSide(
                      color: Colors.white30,
                      width: 3,
                      style: BorderStyle.solid
                  ), borderRadius: BorderRadius.circular(15)),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                FlatButton.icon(color: btditerim ? Colors.green : Colors.grey,
                  onPressed: (){
                    gantiTombol("diterima");
                    fetchData("diterima");
                  },
                  icon: Icon(Icons.money_off, color: Colors.white,), label: Text("Diterima", style: TextStyle(color: Colors.white),),
                  shape: RoundedRectangleBorder(side: BorderSide(
                      color: Colors.white30,
                      width: 3,
                      style: BorderStyle.solid
                  ), borderRadius: BorderRadius.circular(15)),
                ),
              ],
            ),
          ),

          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: loading2 ?
        Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20),
              ),
              Text('Transaksi Kosong, Silahkan Belanja..'),
              Text('Tekan Menu Home Untuk Mulai Belanja'),
            ],
          ),
        )
            : loading ? Center(child: CircularProgressIndicator(),) : Container(
            child: Column(
              children: <Widget>[

                Expanded(
                  child:
                  ListView.builder(

                    itemCount: _list.length,
                    itemBuilder: (context, i) {
                      final a = _list[i];
//
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => Detail_Transaksi(kirimid: a.resi)));
                        },
                       child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: Card(
                          elevation:5,
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
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
                                    Text("Resi: ${a.resi}", style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0, color: Colors.black),),
                                    Text("Rp.${a.total}", style: TextStyle(
                                        fontSize: 14.0, color: Colors.black),),

                                    Text("${a.w_order}", style: TextStyle(
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic),),
                                    Divider(),
                                    Text("${a.status}", style: TextStyle(
                                        fontSize: 14.0, color: Colors.black),),
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                    ),
                                  ],
                                ),
                              trailing:
                               Container(
                                width: 80.0,
                                height: 100.0,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: new NetworkImage(
                                            "https://leonybuah.com/"+a.gambar)
                                    )
                                ),
                              ),
                            ),

                          ],),
                        ),
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
}
