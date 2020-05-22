import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:tas_murah/model/model_detai_transaksi.dart';
import 'package:tas_murah/page/upload_bukti.dart';

class Detail_Transaksi extends StatefulWidget {
  @override
  _Detail_TransaksiState createState() => _Detail_TransaksiState();
  final String kirimid;

  Detail_Transaksi({Key key, @required this.kirimid}) : super();
}

class _Detail_TransaksiState extends State<Detail_Transaksi> {
  String idbarang = '0', iduser='0';
  var rating = 0.0;

  int totald=0;
  String nama='', status='', diskon='',  gambar='', alamat ='';
  var loading = false;
  var loading2= false;
  var blm_bayar= false;

  TextEditingController txttanggap = TextEditingController();
  List<Model_Detail_Transaksi> _list =[];

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
    String xyy = "https://leonybuah.com/api/detail_transaksi.php?mode=detail&resi="+idbarang+"&user="+iduser;
    final response = await http.get(xyy);
    final datad = jsonDecode(response.body);
    if (datad.length > 0) {
      setState(() {
        nama = datad['nama'];
        gambar = datad['gambar'];
        totald = int.parse(datad['total']);
        alamat = datad['alamat'];
        status = datad['status'];
        if(status=="Belum Bayar"){
          blm_bayar = true;
        }else{
          blm_bayar = false;
        }
        loading = false;
      });
    }
  }

  Future<Null> DataFeed() async {
    setState(() {
      loading2 = true;
    });
    _list.clear();
    String xyy = "https://leonybuah.com/api/detail_transaksi.php?mode=item&resi="+idbarang+"&user="+iduser;
    final response = await http.get(xyy);
    if (response.statusCode == 200) {
      final datay = jsonDecode(response.body);
      setState(() {
        for (Map k in datay) {
          _list.add(Model_Detail_Transaksi.dariJson(k));
          loading2 = false;
        }
      });
    }
  }

  sendTanggapan() async {
    setState(() {

    });
    String xyy = "https://leonybuah.com/api/tanggapan.php?mode=send&rating=$rating&user=$iduser&tanggapan"
        "=${txttanggap.text}&resi=${widget.kirimid}";
    final response = await http.get(xyy);
    if (response.statusCode == 200) {
      final datay = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("${datay['pesan']}"),
            actions: <Widget>[
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
    }else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Masalah Gangguan Jaringan.."),
            actions: <Widget>[
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

  _popTanggapan() async{
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Tanggapan.."),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: <Widget>[
                  SmoothStarRating(
                      allowHalfRating: false,
                      onRatingChanged: (v) {

                        setState(() {
                          rating = v;
                        });
                        print(rating);
                        Navigator.of(context).pop();
                        _popTanggapan();

                      },
                      starCount: 5,
                      rating: rating,
                      size: 40.0,
                      color: Colors.green,
                      borderColor: Colors.green,
                      spacing:0.0
                  ),
                  Divider(),
                  new TextField(
                    maxLines: 5,
                    maxLength: 300,
                    keyboardType:TextInputType.multiline,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Tanggapan",
                      border:
                      new OutlineInputBorder(
                        borderRadius:
                        new BorderRadius
                            .circular(25.0),
                        borderSide:
                        new BorderSide(),
                      ),
                    ),
                    textInputAction:TextInputAction.newline,
                    onSubmitted: null,
                    controller: txttanggap,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 10),
                  ),

                ],
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("Kirim"),
                onPressed: () {
                  sendTanggapan();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "Detail Pembelian",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child:Container(
          color: Colors.white70,
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Text('NO TAGIHAN', style: TextStyle(fontSize: 12),),
              trailing: Text(widget.kirimid, style: TextStyle(fontSize: 18),),
            ),
            new Divider(),
            Container(
              color: Colors.white70,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: blm_bayar ? FlatButton.icon(
                      color: Colors.green,
                      textColor: Colors.white,
                      icon: Icon(Icons.file_upload),
                      label: Text("Unggah Bukti Transfer"),
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => UploadImageBukti(kirimid: idbarang)));
                      },
                    ): FlatButton.icon(
                      color: Colors.green,
                      textColor: Colors.white,
                      icon: Icon(Icons.verified_user),
                      label: Text("Lunas"),
                      onPressed: (){

                      },
                    ),
                  ),
                  new Divider(),
                  new Card(
                  child: ExpansionTile(

                    leading: Text('Total '),
                    title:Text('$totald'),
                    trailing: Text('Rincian',style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
                    children: <Widget>[
                      ListTile(
                        leading: Text('Total Harga Barang'),
                        trailing: Text('Rp.$totald'),
                      ),
                      ListTile(
                        leading: Text('Biaya Pengiriman'),
                        trailing: Text('Rp.10.000'),
                      ),
                    ],
                  ),
                  ),
                  Card(
                  child:ListTile(
                    leading: Text('MOTODE PEMBAYARAN'),
                    trailing: Text('Transfer Bank'),
                  ),
                  ),
                  Card(
                 child: ExpansionTile(

                    leading: Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold),),

                    children: <Widget>[
                      ListTile(
                        title: Text('$nama',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                        subtitle: Text('$alamat'),
                      )
                      ]
                  ),
                  ),
                 ListTile(
                    leading: Text('Informasi Pembelian'),

                  ),
                  ListTile(
                    leading: Text('NOMOR TRANSAKSI'),
                    trailing: Text('${widget.kirimid}'),
                  ),
                  ListTile(
                    leading: Text('STATUS '),
                    trailing: Text("$status"),
                  ),

                  new Divider(),
                ],
              ),
            ),
      Card(
        child: ExpansionTile(
          leading: Text('ITEM BARANG'),
            children:<Widget>[
            SizedBox(
              height: 400,
              child:
              ListView.builder(
                itemCount: _list.length,
                itemBuilder: (context, i){
                  final a = _list[i];
                  return Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
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
                                        image: new NetworkImage('https://leonybuah.com/'+a.gambar)
                                    )
                                ),
                              ),
                              title:
                              Text(a.nama_barang, style: TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: 14.0, color: Colors.green),),
                              subtitle: Text('Jumlah: '+a.jumlah+'\nTotal Harga: '+a.total, style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic ),)
                          ),
                        ],
                        ),
                      )
                  );
                },
              ),

            )
              ]
        )
      ),
            Card(
              child: Column(
                children: <Widget>[
              ListTile(
              title: FlatButton.icon(
                color: Colors.green,
                textColor: Colors.white,
                icon: Icon(Icons.chat),
                label: Text("Beri Tanggapan"),
                onPressed: () {
                  _popTanggapan();
                },
              ),
//                trailing: FlatButton.icon(
//                  color: Colors.green,
//                  textColor: Colors.white,
//                  icon: Icon(Icons.chat_bubble, color: Colors.redAccent,),
//                  label: Text("Komplain"),
//                  onPressed: () {
//                    Navigator.push(
//                        context, MaterialPageRoute(builder: (context) => UploadImageBukti(kirimid: idbarang)));
//                  },
//                ),
              )
                ],
              ),
            )
          ],
        ),
      ),
      )
    );
  }
}
