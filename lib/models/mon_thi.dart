class MonThi {
  final int stt;
  final String maHP;
  final String tenHP;
  final int soTC;
  final String ngayThi;
  final String caThi;
  final String hinhThucThi;
  final String soBaoDanh;
  final String phongThi;
  final String ghiChu;

  MonThi({
    required this.stt,
    required this.maHP,
    required this.tenHP,
    required this.soTC,
    required this.ngayThi,
    required this.caThi,
    required this.hinhThucThi,
    required this.soBaoDanh,
    required this.phongThi,
    required this.ghiChu,
  });

  // Constructor factory để tạo đối tượng từ một Map
  factory MonThi.fromMap(Map<String, dynamic> map) {
    return MonThi(
      stt: int.parse(map['STT'] as String),
      maHP: map['MaHP'] as String,
      tenHP: map['TenHP'] as String,
      soTC: int.parse(map['SoTC'] as String),
      ngayThi: map['Ngay'] as String,
      caThi: map['CaThi'] as String,
      hinhThucThi: map['HinhThuc'] as String,
      soBaoDanh: map['SBD'] as String,
      phongThi: map['DiaDiem'] as String,
      ghiChu: map['GhiChu'] as String,
    );
  }
}