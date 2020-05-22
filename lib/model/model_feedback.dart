class Model_Feed{
  final String idbarang;
  final String nama;
  final String foto;
  final String waktu;
  final String rating;
  final String pesan;

  Model_Feed({this.idbarang, this.nama, this.foto, this.waktu,this.rating, this.pesan});

  factory Model_Feed.dariJson(Map<String, dynamic>djson){
    return new Model_Feed(
      idbarang: djson['idbarang'],
      nama:djson['nama'],
      foto: djson['foto'],
      waktu: djson['waktu'],
      rating: djson['rating'],
      pesan: djson['pesan'],
    );
  }
}
