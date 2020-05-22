class Model_Detail_Transaksi{

  final String idbarang;
  final String nama_barang;
  final String harga;
  final String diskon;
  final String jumlah;
  final String total;
  final String gambar;

  Model_Detail_Transaksi({this.idbarang,this.nama_barang,this.harga, this.diskon, this.jumlah, this.total, this.gambar});

  factory Model_Detail_Transaksi.dariJson(Map<String, dynamic>djson){
    return new Model_Detail_Transaksi(
      idbarang: djson['idbarang'],
      nama_barang: djson['nama_barang'],
      harga: djson['harga'],
      diskon: djson['diskon'],
      jumlah: djson['jumlah'],
      total: djson['total'],
      gambar: djson['gambar'],
    );
  }
}
