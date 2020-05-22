class Model_Notifikasi{
  final String idnotifikasi;
  final String keranjang;
  final String judul;
  final String pesan;
  final String waktu;
  final String resi;
  final String idbarang;
  final String baca;



  Model_Notifikasi({this.idnotifikasi,this.keranjang, this.judul, this.pesan, this.waktu,this.resi,this.idbarang, this.baca});

  factory Model_Notifikasi.dariJson(Map<String, dynamic>djson){
    return new Model_Notifikasi(
      idnotifikasi: djson['idnotifikasi'],
      keranjang: djson['keranjang'],
      judul: djson['judul'],
      pesan: djson['pesan'],
      waktu: djson['waktu'],
      resi: djson['resi'],
      idbarang: djson['idbarang'],
      baca: djson['baca'],
    );
  }
}
