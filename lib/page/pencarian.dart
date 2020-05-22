import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tas_murah/model/model_home.dart';




class Pencarian extends StatefulWidget {
  @override
  _PencarianState createState() => _PencarianState();
}

class _PencarianState extends State<Pencarian> {
  var loading = false;
  List<Model_Home> _list =[];
  TextEditingController txtcr = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  pesanalert(judul, pesan) async{
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("$judul"),
          content: new Text("$pesan"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Tutup"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<Null> fetchData(s) async {
    String scr = s.toString();
    setState(() {
      loading = true;
    });
    _list.clear();
    String xxx = "https://leonybuah.com/api/list_barang.php?batas=10&cr=$scr";
    print(xxx);
    final response = await http.get(xxx);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data.length);
      if(data.length < 1){
      pesanalert('Pencarian', 'Pencarian tidak ditemukan..\nCoba pencarian lain');
        setState(() {
          for (Map i in data) {
            _list.add(Model_Home.dariJson(i));

          }
          loading = false;
        });
      }else {
        setState(() {
          for (Map i in data) {
            _list.add(Model_Home.dariJson(i));
            loading = false;
          }
        });
      }
    }
  }
  Future<Null> kecari(r)async{
    String s = txtcr.text.toString();
    fetchData(s);
  }
  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int jdata = _list.length;
    return Scaffold(
      appBar: AppBar(
  iconTheme: IconThemeData(
    color: Colors.black, //change your color here
  ),
  backgroundColor: Colors.white,
  title: TextField(
    controller: txtcr,
        textInputAction: TextInputAction.search,
        onSubmitted: kecari,
        decoration: InputDecoration(
        labelText: "Pencarian..",
        filled: true,
        fillColor: Colors.white,
  ),
),
),
      body:loading ? Center(child: CircularProgressIndicator(),):GridView.count(
        crossAxisCount: 2,

        children: List.generate(jdata, (index) {
          final ls = _list[index];
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              margin: EdgeInsets.all(7),
              child: Column(children: <Widget>[
                ListTile(title: Image.network(
                  "https://leonybuah.com/"+ls.gambar,
                  height: 100,
                ),
                    onTap: () {
//                        Navigator.push(
//                            context, MaterialPageRoute(builder: (context) => PerTags(kirimTags: ls.judul,)));
                    }
                ),
                ListTile(
                  title: Text(ls.nama_barang,textAlign: TextAlign.center,),
                  onTap: () {

//                      Navigator.push(
//                          context, MaterialPageRoute(builder: (context) => PerTags(kirimTags: ls.judul,)));
//
                  },
                  subtitle: Text(ls.harga,textAlign: TextAlign.center,),
                ),
              ],)
          );
        }),
      ),
    );
  }

}
