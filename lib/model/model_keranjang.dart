class Model_Keranjang{
  final String keranjang;
  final String idbarang;
  final String nama_barang;
  final String harga;
  final String diskon;
  final String jumlah;
  final String status;
  final String stok;
  final String gambar;

  Model_Keranjang({this.keranjang,this.idbarang,this.nama_barang,this.harga, this.diskon, this.jumlah, this.status,this.stok,this.gambar});

  factory Model_Keranjang.dariJson(Map<String, dynamic>djson){
    return new Model_Keranjang(
      keranjang: djson['keranjang'],
      idbarang: djson['idbarang'],
      nama_barang: djson['nama_barang'],
      harga: djson['harga'],
      diskon: djson['diskon'],
      jumlah: djson['jumlah'],
      status: djson['status'],
      stok: djson['stok'],
      gambar: djson['gambar'],
    );
  }
}
