import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:tas_murah/model/api.dart';
import 'package:tas_murah/model/model_feedback.dart';
import 'package:tas_murah/page/keranjang.dart';


class Detail_Produk extends StatefulWidget {
  @override
  _Detail_ProdukState createState() => _Detail_ProdukState();
  final String kirimid;

  Detail_Produk({Key key, @required this.kirimid}) : super();
}

class _Detail_ProdukState extends State<Detail_Produk> {
String idbarang = '0', iduser='0';
int quanty =1, maxquanty =10;
String total='0';
String barang='', harga='', diskon='',stok='', gambar='', deskripsi ='';
var loading = false;
var loading2= false;

List<Model_Feed> _list =[];

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      iduser = preferences.getString('iduser');
      idbarang = widget.kirimid;
      ambildata();
      DataFeed();
    });
  }

  ambildata() async {
    loading = true;
    final response = await http.post(BaseUrl.getdetailbarang,
        body: {"idbarang": idbarang});
    final data = jsonDecode(response.body);
    int value = data['value'];
    if (value == 1) {
      setState(() {
        barang = data['nama_barang'];
        harga = data['harga'];
        diskon = data['diskon'];
        stok = data['stok'];
        gambar = data['gambar'];
        deskripsi = data['deskripsi'];
        maxquanty = int.parse(stok);
        int blmdiskon = quanty * int.parse(harga);
        double hasil = blmdiskon - ((blmdiskon * int.parse(diskon))/100);
        total = hasil.toString();
        loading = false;
      });
    }
  }

Future<Null> DataFeed() async {
  setState(() {
    loading2 = true;
  });
  _list.clear();
  String xyy = "https://leonybuah.com/api/list_feedback.php?idbarang="+idbarang;
  final response = await http.get(xyy);
  if (response.statusCode == 200) {
    final datay = jsonDecode(response.body);
    setState(() {
      for (Map k in datay) {
        _list.add(Model_Feed.dariJson(k));
        loading2 = false;
      }
    });
  }
}

  void tambah() async{

    setState(() {
      if(quanty >= maxquanty){
        quanty = maxquanty;
      }else{
        quanty = quanty+1;
      }
      int blmdiskon = quanty * int.parse(harga);
      double hasil = blmdiskon - ((blmdiskon * int.parse(diskon))/100);
      total = hasil.toString();
    });
}

void kurang() async{

  setState(() {
    if(quanty <= 1){
      quanty =1;
    }else{
      quanty = quanty-1;
    }
    int blmdiskon = quanty * int.parse(harga);
    double hasil = blmdiskon - ((blmdiskon * int.parse(diskon))/100);
    total = hasil.toString();
  });
}

  @override
  void initState() {
    super.initState();
    getPref();
  }

  perbesargambar() async{
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.network(
            'https://leonybuah.com/$gambar',
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
  }

  Future<Null> TambahKeranjang() async{
    final response = await http.post(BaseUrl.tambahkeranjang,
        body: {"iduser": iduser, "idbarang": idbarang, "jumlah": quanty.toString(),"harga":harga,"diskon":diskon.toString()});

    if(response.statusCode==200) {
      final datares = jsonDecode(response.body);
      int value = datares['value'];
      if (value == 1) {
        Navigator.of(context).pop();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Keranjang()));

      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                'Gagal Menambahkan Produk Ke Kerancang, Silahkan Coba Lagi..',
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
      }
    }else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
              'Gangguan Jaringan. Perikasa Layanan Jaringan Perangkat Anda..',
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
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "$barang",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              width: 200.0,
              height: 200.0,
              alignment: Alignment.bottomCenter,
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.fill, image: new NetworkImage("https://leonybuah.com/$gambar"))),
              child:  FlatButton.icon(
                color: Color.fromRGBO(255, 255, 255, 0.7),
                icon: Icon(Icons.remove_red_eye), //`Icon` to display
                label: Text("View"), //`Text` to display
                onPressed: () {
                  perbesargambar();
                },
              ),
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
                      icon: Icon(Icons.add_shopping_cart),
                      label: Text("to Cart"),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text(
                                'Tambahkan ke Keranjang Sekarang.?',
                              ),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text("Batal"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                new FlatButton(
                                  child: new Text("Tambahkan"),
                                  onPressed: () {
                                    TambahKeranjang();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    title: new Center(
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          new RawMaterialButton(
                            onPressed: () {
                              kurang();
                            },
                            child: new Icon(
                              Icons.remove,
                              color: Colors.red,
                              size: 14.0,
                            ),
                            shape: new CircleBorder(),
                            elevation: 2.0,
                            fillColor: Colors.white,
                            padding: const EdgeInsets.all(15.0),
                          ),

                          new Text('$quanty',
                              style: new TextStyle(fontSize: 20.0)),
                          new RawMaterialButton(
                            onPressed: () {
                              tambah();
                            },
                            child: new Icon(
                              Icons.add,
                              color: Colors.blue,
                              size: 14.0,
                            ),
                            shape: new CircleBorder(),
                            elevation: 2.0,
                            fillColor: Colors.white,
                            padding: const EdgeInsets.all(15.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  new Divider(),
                  ListTile(
                    leading: Text('Total '),
                    title:Text('Rp.$total'),
                  ),
                  ListTile(
                    leading: Icon(Icons.apps),
                    title: Text("$barang"),
                  ),
                  ListTile(
                    leading: Icon(Icons.monetization_on),
                    title: Text('$harga'),
                  ),
                  ListTile(
                    leading: Text('Diskon'),
                    title: Text('$diskon %'),
                  ),
                  ListTile(
                    leading: Text('Stok '),
                    title: Text("$stok"),
                  ),
                  ListTile(
                    leading: Icon(Icons.format_quote),
                    title: new HtmlView(
                      data: "$deskripsi",
                      onLaunchFail: (url) { // optional, type Function

                      },
                      scrollable: false, //false to use MarksownBody and true to use Marksown
                    )
                  ),
                  new Divider(),
                ],
              ),
            ),
            Container(
                color: Colors.green,
                width: double.maxFinite,
                alignment: Alignment.center,
//                    padding: EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text('Feedback Users',textAlign: TextAlign.center,style: TextStyle(color: Colors.white) ),

                    ),
                  ],
                )
            ),
            SizedBox(
              height: 400,
              child:
              ListView.builder(
                itemCount: _list.length,
                itemBuilder: (context, i){
                  final a = _list[i];
                  var crating = double.parse(a.rating);
                  return Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, children: <Widget>[
                        ListTile(
                            leading: Container(
                              width: 80.0,
                              height: 100.0,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new NetworkImage('https://leonybuah.com/'+a.foto)
                                  )
                              ),
                            ),
                            title:
                            Text(a.nama, style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 14.0, color: Colors.green),),
                            subtitle: Text(a.pesan, style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic ),),
                            onTap: () {

                            }
                        ),

                        ListTile(
                          leading: SmoothStarRating(
                              allowHalfRating: false,
                              starCount: 5,
                              rating: crating,
                              size: 15.0,
                              color: Colors.green,
                              borderColor: Colors.green,
                              spacing:0.0
                          ),
                          trailing: Text(a.waktu, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12.0),),
                        )
                      ],
                  ),
                    )
                  );
                },
              ),

            )
          ],
        ),
      ),
    );
  }
}
