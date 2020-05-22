import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tas_murah/model/model_home.dart';
import 'package:tas_murah/model/model_promo.dart';
import 'package:tas_murah/page/detail_produk.dart';




class HomeT extends StatefulWidget {
  @override
  _HomeTState createState() => _HomeTState();
}

class _HomeTState extends State<HomeT> {
  var loading = false;
  var loading_promo = false;
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
    setState(() {
      loading_promo=true;
    });
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
      setState(() {
        loading_promo=false;
      });
    }
  }
  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    int jdata = _list.length;
    int jpromo = _listPromo.length;
    var nf=[];
    var idg = [];
    int we=0;
    for(var n=0;n< jpromo;n++){
      final ad = _listPromo[n];
      nf.add(ad.gambarp);
      idg.add(ad.idbarangp);
    }
    double tinggi = jdata > 0 ? MediaQuery.of(context).size.height-270 : MediaQuery.of(context).size.height-200;

    Widget img_slide = new Container(

//      padding: EdgeInsets.all(10),
      height: 130,
      child: Card(

      child: loading_promo ?Center(child: CircularProgressIndicator(),) : CarouselSlider(
        items:
         nf.map((i) {
           int cs = we++;
          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Detail_Produk(kirimid: '${idg[cs]}'),
                    ),
                  );
                },
                  child:Container(
                margin: EdgeInsets.all(10),
                    height: 100.0,
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.5)),
                        shape: BoxShape.rectangle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage( "https://leonybuah.com/$i"))),
                  ),
              );
            },
          );
        }).toList(),
        aspectRatio: 16/9,
        viewportFraction: 0.8,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        pauseAutoPlayOnTouch: Duration(seconds: 10),
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
      )

      )
    );

    Widget konten_satu = new Container(
      height: tinggi,
      child: loading ? Center(child: CircularProgressIndicator(),):GridView.count(
      crossAxisCount: 2,

      children: List.generate(jdata, (index) {
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
      )
    );
    return Scaffold(
      body: ListView(
        children: <Widget>[
          img_slide,
          konten_satu
        ],
      )
    );
  }

}
