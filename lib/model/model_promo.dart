class Model_Promo{
  final String idbarangp;
  final String nama_barangp;
  final String hargap;
  final String gambarp;
  final String diskonp;
  Model_Promo({this.idbarangp, this.nama_barangp, this.hargap, this.gambarp, this.diskonp});

  factory Model_Promo.drJson(Map<String, dynamic>kjson){
    return new Model_Promo(
      idbarangp: kjson['idbarang'],
      nama_barangp:kjson['nama_barang'],
      hargap: kjson['harga'],
      gambarp: kjson['gambar'],
      diskonp: kjson['diskon'],
    );
  }
}
