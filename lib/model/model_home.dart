class Model_Home{
  final String idbarang;
  final String nama_barang;
  final String harga;
  final String gambar;
  final String diskon;
  Model_Home({this.idbarang, this.nama_barang, this.harga, this.gambar, this.diskon});

  factory Model_Home.dariJson(Map<String, dynamic>djson){
    return new Model_Home(
      idbarang: djson['idbarang'],
      nama_barang:djson['nama_barang'],
      harga: djson['harga'],
      gambar: djson['gambar'],
      diskon: djson['diskon'],
    );
  }
}
