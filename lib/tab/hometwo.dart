import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tas_murah/model/model_home.dart';
import 'package:tas_murah/model/model_promo.dart';
import 'package:tas_murah/page/detail_produk.dart';




class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var loading = false;
  List<Model_Home> _list =[];
  List<Model_Promo> _listPromo =[];
  @override
  void initState() {
    super.initState();
    fetchPromo();
    fetchData();

  }

  Future<Null> fetchData() async {
    setState(() {
      loading = true;
    });
    _list.clear();
    String xxx = "https://leonybuah.com/api/list_barang.php?batas=10&cr=";
    final response = await http.get(xxx);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        for (Map i in data) {
          _list.add(Model_Home.dariJson(i));
          loading = false;
        }
      });
    }
  }

  Future<Null> fetchPromo() async {
    _listPromo.clear();
    String xxx = "https://leonybuah.com/api/list_promo.php?batas=10&cr=";
    final response = await http.get(xxx);
    if (response.statusCode == 200) {
      final datap = jsonDecode(response.body);
      if(datap.length > 0) {
        setState(() {
          for (Map i in datap) {
            _listPromo.add(Model_Promo.drJson(i));
          }
        });
      }
    }
  }
  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    int jdata = _listPromo.length;
    int jhome = _list.length;
    double tinggi = jdata > 0 ? MediaQuery.of(context).size.height-300 : MediaQuery.of(context).size.height-200;
    return Scaffold(
      body: Column(
          mainAxisSize: MainAxisSize.min,
        children:<Widget>[
          SizedBox(
            height: jdata>0 ? 140.0: 0,
            child: Card(
              child:PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: _listPromo.length,
              itemBuilder: (BuildContext context, int itemIndex) {
                final a = _listPromo[itemIndex];
                return Center(
                  // padding: EdgeInsets.symmetric(horizontal: 0.1),
                    child:SingleChildScrollView(
                      child:Center(
                        child: Column(
                          // mainAxisSize: MainAxisSize.min,
                          children: <Widget>[

                            Text('Spesial Promo', style: TextStyle(fontWeight: FontWeight.bold),),
                            ListTile(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Detail_Produk(kirimid: a.idbarangp),
                                  ),
                                );
                              },
                              title: Container(
                                width: 80.0,
                                height: 100.0,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: new NetworkImage( "https://leonybuah.com/"+a.gambarp))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                );
              },
            ),
            ),
          ),
        SizedBox(
          height: tinggi,
        child: loading ? Center(child: CircularProgressIndicator(),):GridView.count(
        crossAxisCount: 2,

        children: List.generate(jhome, (index) {
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
                          color: Colors.white.withOpacity(0.47),
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
                                subtitle: Text('Rp.'+ls.harga,textAlign: TextAlign.center,style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          )
                      ),

                    ],
                  ),
                ),
              )
          );
        }),
      ),
        )
    ]
      )
    );
  }

}
