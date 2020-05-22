import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tas_murah/model/model_home.dart';
import 'package:tas_murah/page/detail_produk.dart';
class Promo extends StatefulWidget {
  @override
  _PromoState createState() => _PromoState();
}

class _PromoState extends State<Promo> {
  String iduser ='0';
  var loading = false;
  var loading2 = false;
  List<Model_Home> _list =[];

  getPref()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      iduser = preferences.get("iduser");
    });
    fetchData();
  }
  @override
  void initState() {
    super.initState();
    getPref();
    waktuubah();
  }

  @override
  void dispose(){
    super.dispose();
    waktuubah();
    waktuubah2();
  }

  Future<Null> fetchData() async {
    setState(() {
      loading = true;
    });
    _list.clear();
    String xxx = "https://leonybuah.com/api/list_promo.php?batas=10&cr=";
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
                  'Upss... Belum ada promo hari ini..'
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
            _list.add(Model_Home.dariJson(i));
            loading = false;
          }
        });
      }
    }
  }
  var rng = new Random();
  List<Color> _colors = [ //Get list of colors
    Colors.white,
    Colors.cyanAccent,
    Colors.yellowAccent,
    Colors.redAccent,
    Colors.lightBlue
  ];
  int _currentIndex =0;
  waktuubah() async{
    await new Future.delayed(const Duration(seconds: 1));
    setState(() {
      _currentIndex = rng.nextInt(4);
    });
    waktuubah2();
  }

  waktuubah2() async{
    await new Future.delayed(const Duration(seconds: 1));
    setState(() {
_currentIndex= rng.nextInt(4);
    });
    waktuubah();
  }
  TabController _tabController;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: loading2 ?
        Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 60),
              ),
              Text('Belum ada promo, klik menu Home untuk belanja'),
//              FlatButton.icon(color: Colors.green, onPressed: (){
//                _tabController.animateTo(0);
//              }, icon: Icon(Icons.add_shopping_cart, color: Colors.white,), label: Text("Belanja Sekarang", style: TextStyle(color: Colors.white),),
//                shape: RoundedRectangleBorder(side: BorderSide(
//                    color: Colors.white30,
//                    width: 3,
//                    style: BorderStyle.solid
//                ), borderRadius: BorderRadius.circular(50)),
//              ),
            ],
          ),
        )
            : loading ? Center(child: CircularProgressIndicator(),): GridView.count(
          crossAxisCount: 2,

          children: List.generate(_list.length, (index) {
            final ls = _list[index];
            return Container(
                child:Card(
                  elevation: 5,
                  margin: EdgeInsets.all(7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child:Container(

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.5)),
                      image: DecorationImage(
//              colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.dstATop),
                        image:  new NetworkImage(
                            "https://leonybuah.com/"+ls.gambar),
                        fit: BoxFit.fill,
                      ),
                    ),


                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                            color: _colors[_currentIndex].withOpacity(0.47),
                            width: double.maxFinite,
                            alignment: Alignment.center,
//                    padding: EdgeInsets.symmetric(vertical: 2),
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text(ls.nama_barang,textAlign: TextAlign.center,style: TextStyle(color: Colors.black) ),
                                  onTap: () {
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => Detail_Produk(kirimid: ls.idbarang,)));
                                  },
                                  subtitle: Text('Rp.'+ls.harga+' dis '+ls.diskon+' %',textAlign: TextAlign.center,style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            )
                        ),

                      ],
                    ),
                  ),
                )
            );
          })
        )
        );

  }
}
