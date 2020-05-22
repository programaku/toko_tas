class Model_Transaksi{
  final String keranjang;
  final String idbarang;
  final String nama_barang;
  final String harga;
  final String diskon;
  final String jumlah;
  final String status;
  final String total;
  final String gambar;
  final String resi;
  final String w_order;

  Model_Transaksi({this.keranjang,this.idbarang,this.nama_barang,this.harga, this.diskon, this.jumlah, this.status,this.total,this.gambar, this.resi, this.w_order});

  factory Model_Transaksi.dariJson(Map<String, dynamic>djson){
    return new Model_Transaksi(
      keranjang: djson['keranjang'],
      idbarang: djson['idbarang'],
      nama_barang: djson['nama_barang'],
      harga: djson['harga'],
      diskon: djson['diskon'],
      jumlah: djson['jumlah'],
      status: djson['status'],
      total: djson['total'],
      gambar: djson['gambar'],
      resi: djson['resi'],
      w_order: djson['waktu'],

    );
  }
}
