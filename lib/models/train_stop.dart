class TrainStop {
  final int id;
  final String trainNo;
  final String stationName;
  final String departureTime;
  final int departureMinutes;
  final int stopSequence;
  final String? pfNum;
  final String? pfSide;

  TrainStop({
    required this.id,
    required this.trainNo,
    required this.stationName,
    required this.departureTime,
    required this.departureMinutes,
    required this.stopSequence,
    this.pfNum,
    this.pfSide,
  });

  factory TrainStop.fromMap(Map<String, dynamic> map) {
    return TrainStop(
      id: map['id'] ?? 0,
      trainNo: map['train_no'] ?? '',
      stationName: map['station_name'] ?? '',
      departureTime: map['departure_time'] ?? '',
      departureMinutes: map['departure_minutes'] ?? 0,
      stopSequence: map['stop_sequence'] ?? 1,
      pfNum: map['pf_num'],
      pfSide: map['pf_side'],
    );
  }
}
