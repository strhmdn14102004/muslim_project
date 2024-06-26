class AzanItem {
  int? id;
  String? lokasi;
  String? daerah;
  Jadwal jadwal;

  AzanItem({
    this.id,
    this.lokasi,
    this.daerah,
    required this.jadwal,
  });

  factory AzanItem.fromJson(Map<String, dynamic> json) => AzanItem(
        id: json["id"],
        lokasi: json["lokasi"],
        daerah: json["daerah"],
        jadwal: Jadwal.fromJson(json["jadwal"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "lokasi": lokasi,
        "daerah": daerah,
        "jadwal": jadwal.toJson(),
      };
}

class Jadwal {
  String? tanggal;
  String? imsak;
  String? subuh;
  String? terbit;
  String? dhuha;
  String? dzuhur;
  String? ashar;
  String? maghrib;
  String? isya;
  DateTime date;

  Jadwal({
    this.tanggal,
    this.imsak,
    this.subuh,
    this.terbit,
    this.dhuha,
    this.dzuhur,
    this.ashar,
    this.maghrib,
    this.isya,
    required this.date,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) => Jadwal(
        tanggal: json["tanggal"],
        imsak: json["imsak"],
        subuh: json["subuh"],
        terbit: json["terbit"],
        dhuha: json["dhuha"],
        dzuhur: json["dzuhur"],
        ashar: json["ashar"],
        maghrib: json["maghrib"],
        isya: json["isya"],
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "tanggal": tanggal,
        "imsak": imsak,
        "subuh": subuh,
        "terbit": terbit,
        "dhuha": dhuha,
        "dzuhur": dzuhur,
        "ashar": ashar,
        "maghrib": maghrib,
        "isya": isya,
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      };
}

class Request {
  String path;
  String year;
  String month;
  String date;

  Request({
    required this.path,
    required this.year,
    required this.month,
    required this.date,
  });

  factory Request.fromJson(Map<String, dynamic> json) => Request(
        path: json["path"],
        year: json["year"],
        month: json["month"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "path": path,
        "year": year,
        "month": month,
        "date": date,
      };
}
