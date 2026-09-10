class Station {
  final int id;
  final String name;
  final String line;
  final String? stationCode;
  final String? pfSideDn;
  final String? pfSideUp;
  final String? pfNumDn;
  final String? pfNumUp;

  Station({
    required this.id,
    required this.name,
    required this.line,
    this.stationCode,
    this.pfSideDn,
    this.pfSideUp,
    this.pfNumDn,
    this.pfNumUp,
  });

  factory Station.fromMap(Map<String, dynamic> map) {
    return Station(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      line: map['line'] ?? '',
      stationCode: map['station_code'],
      pfSideDn: map['pf_side_dn'],
      pfSideUp: map['pf_side_up'],
      pfNumDn: map['pf_num_dn'],
      pfNumUp: map['pf_num_up'],
    );
  }
}
