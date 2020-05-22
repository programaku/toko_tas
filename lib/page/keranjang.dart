import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tas_murah/model/api.dart';
import 'package:tas_murah/model/model_keranjang.dart';

class Keranjang extends StatefulWidget {
  @override
  _KeranjangState createState() => _KeranjangState();
}

class _KeranjangState extends State<Keranjang> {
  final globalKey = GlobalKey<ScaffoldState>();
  double semua =1;
  String iduser ='0';
  var loading = false;
  var loading2 = false;
  var loading3 = false;
  var loading4 = false;
  var ada_promo = false;
  var gunakan = false;
  List<Model_Keranjang> _list =[];

  String bayarkeranjang='';

  String kode_promo='', adap='', kode_dis='', expire='';
  getPref()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      iduser = preferences.get("iduser");
    });
    fetchData();
    Cek_Promo();
  }
  @override
  void initState() {
    super.initState();
    gunakan=false;
    getPref();

  }

  @override
  void dispose(){
    super.dispose();
  }


  Future<Null> Cek_Promo() async {
    String xy_link = "https://leonybuah.com/api/cek_kode_promo.php?mode=cek_promo&iduser=$iduser";
    final response = await http.get(xy_link);
    if (response.statusCode == 200) {
      final datacek = jsonDecode(response.body);
      setState(() {
        adap = datacek['kode'];
        kode_dis = datacek['diskon'];
        expire = datacek['expire'];
        if (adap == '0') {
          ada_promo = false;
        } else {
          ada_promo = true;
        }

      });
    }

  }

  Future<Null> fetchData() async {

    setState(() {
      loading = true;
      loading4= true;
    });
    _list.clear();
    String xxx = "https://leonybuah.com/api/keranjang.php?mode=list&user=$iduser";
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
                'Keranjang Kosong..'
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
            _list.add(Model_Keranjang.dariJson(i));
            loading = false;
          }
         ulang();
        });

      }

    }

  }


  Future<Null> ulangData(d) async {
    setState(() {
      semua=0;
      loading4=true;
    });
    String xxx = "https://leonybuah.com/api/keranjang.php?mode=list&user=$iduser";
    final response = await http.get(xxx);
    bayarkeranjang='';
    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      _list.removeRange(0,data.length);
      bayarkeranjang='';

      await new Future.delayed(const Duration(seconds: 1));
      _list.clear();
        setState(() {
          for (Map i in data) {
            _list.add(Model_Keranjang.dariJson(i));

          }
          loading3=false;
          if(d=="byr"){
            loading4=false;
          }

        });
      }

  }

  Future<Null> Gunakan_Voucher() async{
    String x_link = "https://leonybuah.com/api/cek_kode_promo.php?mode=gunakan_promo&iduser=$iduser&voc=$adap";
    print(x_link);
    final response = await http.get(x_link);
    if(response.statusCode== 200){
      final data = jsonDecode(response.body);
      print(data);
      showSnackbar(context, 'Berhasil Gunakan Voucher');
      setState(() {
        gunakan = true;
        ulangData('');
        ulang();
      });
    }else{
      showSnackbar(context, 'Masalah Jaringan..');
      setState(() {
        gunakan = false;
      });

    }
  }

  ulang()async{
    await new Future.delayed(const Duration(seconds: 5));
      ulangData("byr");
  }

  Future<Null>AksiDel(idz) async{
    String xxx = "https://leonybuah.com/api/keranjang.php?mode=delete&keranjang=$idz";
    final response = await http.get(xxx);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ulangData('');
      ulang();
    }
  }

void DelKeranjang(nm,id) async{
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(
            'Yakin Ingin Hapus $nm'
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Batal"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          new FlatButton(
            child: new Text("Ya"),
            onPressed: () {
              AksiDel(id);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


 Future<Null>tambah(x,y,mx) async{
     int xy;
     int max = int.parse(mx);
    String jx=x;
    int idx = int.parse(y);
    xy = idx + 1;
    if(xy >= max){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  'Upss.. tidak boleh melebihi stok \n\nStok tersedia hanya $max'
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Tutup"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
            );
      xy= max;
    }
    String xxx = "https://leonybuah.com/api/keranjang.php?mode=update&keranjang=$jx&jumlah=$xy";
    print(xxx);
    final response = await http.get(xxx);
    if (response.statusCode == 200) {
      ulangData('');
      ulang();
    }
  }

 Future<Null>kurang(x,y) async{
    int xy;
    String jx=x;
    int idx = int.parse(y);
    xy = idx - 1;
    if(xy <1){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  'Upss.. tidak boleh nol (0) stok \n\nMinimal pesanan adalah 1'
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Tutup"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
      );
      xy = 1;
    }
    String xxx = "https://leonybuah.com/api/keranjang.php?mode=update&keranjang=$jx&jumlah=$xy";
    final response = await http.get(xxx);
    if (response.statusCode == 200) {
      ulangData('');
      ulang();
    }
  }

  Future<Null>AksiBayar() async {
    final response = await http.post(BaseUrl.bayarkeranjang,
        body: {"iduser": iduser, "keranjang": bayarkeranjang});

    if (response.statusCode == 200) {
      final datares = jsonDecode(response.body);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                    'Proses Bayar Sukses, Silahkan Transfer Sesuai Nominal Angka'
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("Tutup"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => Keranjang()));
                    },
                  ),
                ],
              );
            }
        );
    }else{
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Masalah Jaringan..'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: globalKey,

        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            "Keranjang",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: loading2 ?
        Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 60),
            ),
            Text('Keranjang Kosong, Silahkan Belanja..'),
            FlatButton.icon(color: Colors.green, onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(Icons.add_shopping_cart, color: Colors.white,), label: Text("Belanja Sekarang", style: TextStyle(color: Colors.white),),
                shape: RoundedRectangleBorder(side: BorderSide(
                color: Colors.white30,
                width: 3,
                style: BorderStyle.solid
            ), borderRadius: BorderRadius.circular(50)),
            ),
          ],
        ),
        )
            : loading ? Center(child: CircularProgressIndicator(),) :  Container(
            child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: ada_promo ? Card(
                      color: Colors.greenAccent,
                      child: ListTile(
                        leading: Text('Kode \nVoucher ',  textAlign: TextAlign.center,),
                        title: Text('$adap', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
                        subtitle: Text('Dis ($kode_dis%)', textAlign: TextAlign.center,),
                        trailing: FlatButton.icon(
                            onPressed: (){
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // return object of type Dialog
                                  return AlertDialog(
                                    title: new Text("Konfirmasi"),
                                    content: new Text("Voucher hanya bisa digunakan SATU KALI dan akan berakhir pada $expire. Gunakan sekarang.?"),
                                    actions: <Widget>[
                                      // usually buttons at the bottom of the dialog
                                      new FlatButton(
                                        child: new Text("Nanti"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      new FlatButton(
                                        child: new Text("Gunakan"),
                                        onPressed: () {
                                          gunakan ? '' : Gunakan_Voucher();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                            },
                            icon: Icon(gunakan ? Icons.check_box : Icons.check_box_outline_blank , color: Colors.white,), label: Text("Gunakan", style: TextStyle(color: Colors.white),),color: Colors.green,
                            shape: RoundedRectangleBorder(side: BorderSide(
                              color: Colors.white30,
                              width: 3,
                              style: BorderStyle.solid
                          ), borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ):  Text('')
                ),
                Expanded(
                  child:
                  ListView.builder(

                    itemCount: _list.length,
                    itemBuilder: (context, i){
                      final a = _list[i];
                      String totalx='0';
                      String hargay ='';
                      int hargax = int.parse(a.harga);
                      int diskonx = int.parse(a.diskon);

                      int hasilawy = hargax * int.parse(a.jumlah);
                      double hasil = hargax - ((hargax * (diskonx))/100);
                      double hasil2= hasil * int.parse(a.jumlah);
                      totalx = hasil2.toString();
                        semua += hasil2;

                      bayarkeranjang += a.keranjang+'_';

                      if(diskonx>0){
                        hargay = 'Rp.$hasilawy';
                      }else{
                        hargay ='';
                      }
                      return Container(
                        padding: EdgeInsets.all(10.0),
                        child: Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min, children: <Widget>[
                            ListTile(
                                trailing: Container(
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
                                leading:
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.nama_barang, style: TextStyle(fontWeight: FontWeight.bold,
                                    fontSize: 14.0, color: Colors.black),),
                                    Text(hargay, style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic ,decoration: TextDecoration.lineThrough),),
                                    Text(' Rp.'+totalx, style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic ),),
                                  ],
                                )
//
                            ),
                            ListTile(
//                              title: Text('Qty: '+a.jumlah+' item', style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 13),),
                              title: Row(
                                children: <Widget>[
                                  loading3 ? Center(
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      margin: EdgeInsets.all(5),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor : AlwaysStoppedAnimation(Colors.green),
                                      ),
                                    ),
                                  ) : new RawMaterialButton(
                                    onPressed: () {
                                      kurang(a.keranjang,a.jumlah);
                                      setState(() {
                                        loading3 =true;
                                      });
                                    },
                                    child:  new Icon(
                                      Icons.remove,
                                      color: Colors.red,
                                      size: 12.0,
                                    ),
                                    shape: new CircleBorder(),
                                    elevation: 2.0,
                                    fillColor: Colors.white,
                                    padding: const EdgeInsets.all(12.0),
                                  ),

                                  new Text(a.jumlah,
                                      style: new TextStyle(fontSize: 14.0)),
                                  loading3 ? Center(
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      margin: EdgeInsets.all(5),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor : AlwaysStoppedAnimation(Colors.green),
                                      ),
                                    ),
                                  ) : new RawMaterialButton(
                                    onPressed: () {
                                      tambah(a.keranjang,a.jumlah, a.stok);
                                      setState(() {
                                        loading3=true;
                                      });
                                    },
                                    child: new Icon(
                                      Icons.add,
                                      color: Colors.blue,
                                      size: 12.0,
                                    ),
                                    shape: new CircleBorder(),
                                    elevation: 2.0,
                                    fillColor: Colors.white,
                                    padding: const EdgeInsets.all(15.0),
                                  ),                                ],
                              ),
                              trailing: (FlatButton.icon(onPressed: (){
                                DelKeranjang(a.nama_barang, a.keranjang);
                              }, icon: Icon(Icons.delete, color: Colors.red,), label: Text(""))),
                            )
                          ],),
                        ),
                      );
                    },
                  ),
                ),
                loading ? FlatButton(child: CircularProgressIndicator(),color: Colors.amber, onPressed: null,):

                ListTile(
                  title: loading4 ?
                  Text('')
                      :Text('Total: Rp.$semua', style: TextStyle(fontWeight: FontWeight.bold),),
                  trailing: loading4 ?
                  CircularProgressIndicator()

                  :
                  FlatButton.icon(color: Colors.green, onPressed: (){
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                                'Proses pembayaran sekarang.?'
                            ),
                            actions: <Widget>[
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
                                  AksiBayar();
                                },
                              ),
                            ],
                          );
                        }
                    );
              }, icon: Icon(Icons.monetization_on, color: Colors.white,), label: Text("Bayar", style: TextStyle(color: Colors.white),),
                shape: RoundedRectangleBorder(side: BorderSide(
                    color: Colors.white30,
                    width: 3,
                    style: BorderStyle.solid
                ), borderRadius: BorderRadius.circular(15)),
              ),
                )

              ],
                 )
        )

    );

  }
  void showSnackbar(BuildContext context, String st) {
    final snackBar = SnackBar(content: Text('$st'));
    globalKey.currentState.showSnackBar(snackBar);
  }
}


