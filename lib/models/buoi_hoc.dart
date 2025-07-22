class BuoiHoc {
  final String tu;
  final String den;
  final String? mocTG;
  final String? tietHoc;
  final String? tenHP;
  final String? giangVien;
  final String? meet;
  final String? thoiGian;
  final String? diaDiem;
  final String? tuan;

  BuoiHoc({
    required this.tu,
    required this.den,
    this.mocTG,
    this.tietHoc,
    this.tenHP,
    this.giangVien,
    this.meet,
    this.thoiGian,
    this.diaDiem,
    this.tuan,
  });

  factory BuoiHoc.fromJson(Map<String, dynamic> json) => BuoiHoc(
        tu: json['Tu'] ?? '',
        den: json['Den'] ?? '',
        mocTG: json['Ngay'],
        tietHoc: json['TietHoc'],
        tenHP: json['TenHP'],
        giangVien: json['GiangVien'],
        meet: json['Meet'],
        thoiGian: json['ThoiGian'],
        diaDiem: json['DiaDiem'],
        tuan: json['Tuan'],
      );
}
