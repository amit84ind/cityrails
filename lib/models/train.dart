import 'train_stop.dart';

class Train {
  final String trainNo;
  final String line;
  final String trainCode;
  final String origin;
  final String destination;
  final String direction;
  final bool isAc;
  final bool isFast;
  final int coaches;
  final String startTime;
  final String endTime;
  
  // Dynamic fields populated at runtime for station queries
  String? nextStation;
  String? currentStatus;
  int delayMinutes;
  String? stationDepartureTime;
  String? platformNumber;
  String? platformSide;
  List<TrainStop>? stops;

  Train({
    required this.trainNo,
    required this.line,
    required this.trainCode,
    required this.origin,
    required this.destination,
    required this.direction,
    required this.isAc,
    required this.isFast,
    required this.coaches,
    required this.startTime,
    required this.endTime,
    this.nextStation,
    this.currentStatus,
    this.delayMinutes = 0,
    this.stationDepartureTime,
    this.platformNumber,
    this.platformSide,
    this.stops,
  });

  factory Train.fromMap(Map<String, dynamic> map) {
    return Train(
      trainNo: map['train_no'] ?? '',
      line: map['line'] ?? '',
      trainCode: map['train_code'] ?? '',
      origin: map['origin'] ?? '',
      destination: map['destination'] ?? '',
      direction: map['direction'] ?? 'DN',
      isAc: (map['is_ac'] ?? 0) == 1,
      isFast: (map['is_fast'] ?? 0) == 1,
      coaches: map['coaches'] ?? 12,
      startTime: map['start_time'] ?? '',
      endTime: map['end_time'] ?? '',
      stationDepartureTime: map['departure_time'],
      platformNumber: map['pf_num'],
      platformSide: map['pf_side'],
    );
  }
}
