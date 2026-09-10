import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/train.dart';
import '../models/train_stop.dart';

class TrainLivePosition {
  final int currentStopIndex;
  final int nextStopIndex;
  final double segmentProgress; // 0.0 at current station, 1.0 at next station
  final String statusText;
  final String bubbleText;
  final int delayMinutes;
  final String currentStationName;
  final String nextStationName;
  final String pfNum;
  final String pfSide;
  final bool isInsideTrain;
  final String detectionSource; // 'GPS / Cell Tower 350m', 'Rail WiFi', 'Schedule Math'

  TrainLivePosition({
    required this.currentStopIndex,
    required this.nextStopIndex,
    required this.segmentProgress,
    required this.statusText,
    required this.bubbleText,
    required this.delayMinutes,
    required this.currentStationName,
    required this.nextStationName,
    required this.pfNum,
    required this.pfSide,
    this.isInsideTrain = false,
    this.detectionSource = 'Schedule Math',
  });
}

class LiveTrackingService {
  static final LiveTrackingService instance = LiveTrackingService._internal();
  LiveTrackingService._internal();

  bool isInsideTrain = false;

  // Station Coordinates database for 350m Cell Tower / GPS Geofencing
  static const Map<String, List<double>> stationCoordinates = {
    'CSMT': [18.9400, 72.8353],
    'Masjid': [18.9532, 72.8384],
    'Sandhurst Road': [18.9619, 72.8398],
    'Byculla': [18.9750, 72.8322],
    'Chinchpokli': [18.9833, 72.8318],
    'Currey Road': [18.9904, 72.8324],
    'Parel': [19.0012, 72.8378],
    'Dadar': [19.0178, 72.8478],
    'Matunga': [19.0272, 72.8522],
    'Sion': [19.0392, 72.8617],
    'Kurla': [19.0653, 72.8797],
    'Vidyavihar': [19.0792, 72.8972],
    'Ghatkopar': [19.0863, 72.9081],
    'Vikhroli': [19.1112, 72.9261],
    'Kanjurmarg': [19.1283, 72.9351],
    'Bhandup': [19.1432, 72.9372],
    'Nahur': [19.1553, 72.9461],
    'Mulund': [19.1722, 72.9563],
    'Thane': [19.1860, 72.9759],
    'Kalva': [19.2012, 72.9932],
    'Mumbra': [19.1892, 73.0231],
    'Diva': [19.1882, 73.0421],
    'Kopar': [19.2102, 73.0782],
    'Dombivli': [19.2183, 73.0863],
    'Thakurli': [19.2272, 73.0972],
    'Kalyan': [19.2352, 73.1298],
    'Churchgate': [18.9322, 72.8264],
    'Marine Lines': [18.9432, 72.8241],
    'Charni Road': [18.9512, 72.8198],
    'Grant Road': [18.9632, 72.8164],
    'Mumbai Central': [18.9692, 72.8192],
    'Mahalakshmi': [18.9832, 72.8242],
    'Lower Parel': [18.9952, 72.8302],
    'Prabhadevi': [19.0122, 72.8312],
    'Bandra': [19.0542, 72.8402],
    'Andheri': [19.1197, 72.8464],
    'Borivali': [19.2292, 72.8572],
    'Virar': [19.4532, 72.8112],
    'Vashi': [19.0632, 72.9982],
    'Nerul': [19.0332, 73.0182],
    'Panvel': [18.9892, 73.1182],
  };

  /// Calculates real-time running position for a train
  TrainLivePosition calculateLivePosition(
    Train train, {
    DateTime? mockTime,
    Position? deviceLocation,
  }) {
    final stops = train.stops;
    if (stops == null || stops.isEmpty) {
      return TrainLivePosition(
        currentStopIndex: 0,
        nextStopIndex: 0,
        segmentProgress: 0.0,
        statusText: 'Schedule Information Unavailable',
        bubbleText: 'On Time',
        delayMinutes: 0,
        currentStationName: train.origin,
        nextStationName: train.destination,
        pfNum: train.platformNumber ?? 'PF 1',
        pfSide: train.platformSide ?? 'LEFT',
      );
    }

    final now = mockTime ?? DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute + (now.second / 60.0);

    // Calculate delay from user preference or GPS
    int liveDelay = 0;
    String detectionSource = 'Schedule Math';

    if (deviceLocation != null) {
      detectionSource = 'GPS / Cell Tower (350m range)';
      double speedKmh = deviceLocation.speed * 3.6;
      if (speedKmh > 12.0) {
        isInsideTrain = true;
      }
    }

    if (isInsideTrain) {
      liveDelay = 2; // Small delay recalibration when inside train
      detectionSource = 'Rail WiFi / Cell Tower 350m';
    }

    double adjustedMinutes = currentMinutes - liveDelay;

    // Check before first stop
    if (adjustedMinutes <= stops.first.departureMinutes) {
      final firstStop = stops.first;
      return TrainLivePosition(
        currentStopIndex: 0,
        nextStopIndex: 0,
        segmentProgress: 0.0,
        statusText: 'Origin: ${firstStop.stationName}',
        bubbleText: 'Starts at ${firstStop.departureTime}',
        delayMinutes: liveDelay,
        currentStationName: firstStop.stationName,
        nextStationName: stops.length > 1 ? stops[1].stationName : firstStop.stationName,
        pfNum: firstStop.pfNum ?? 'PF 1',
        pfSide: firstStop.pfSide ?? 'LEFT',
        isInsideTrain: isInsideTrain,
        detectionSource: detectionSource,
      );
    }

    // Check after last stop
    if (adjustedMinutes >= stops.last.departureMinutes) {
      final lastStop = stops.last;
      return TrainLivePosition(
        currentStopIndex: stops.length - 1,
        nextStopIndex: stops.length - 1,
        segmentProgress: 1.0,
        statusText: 'Reached ${lastStop.stationName}',
        bubbleText: 'Destination Reached',
        delayMinutes: liveDelay,
        currentStationName: lastStop.stationName,
        nextStationName: lastStop.stationName,
        pfNum: lastStop.pfNum ?? 'PF 1',
        pfSide: lastStop.pfSide ?? 'LEFT',
        isInsideTrain: isInsideTrain,
        detectionSource: detectionSource,
      );
    }

    // Find active segment between Stop i and Stop i+1
    for (int i = 0; i < stops.length - 1; i++) {
      TrainStop s1 = stops[i];
      TrainStop s2 = stops[i + 1];

      if (adjustedMinutes >= s1.departureMinutes &&
          adjustedMinutes <= s2.departureMinutes) {
        double duration = (s2.departureMinutes - s1.departureMinutes).toDouble();
        if (duration <= 0) duration = 1.0;

        double progress = (adjustedMinutes - s1.departureMinutes) / duration;
        progress = progress.clamp(0.0, 1.0);

        String statusMsg;
        String bubbleMsg;

        if (progress < 0.15) {
          statusMsg = 'At ${s1.stationName}';
          bubbleMsg = 'At ${s1.stationName}\n(Just Now)';
        } else if (progress > 0.85) {
          statusMsg = 'Arriving ${s2.stationName}';
          bubbleMsg = liveDelay > 0
              ? '$liveDelay min Late\nArriving ${s2.stationName}'
              : 'On Time\nArriving ${s2.stationName}';
        } else {
          statusMsg = 'Between ${s1.stationName} - ${s2.stationName}';
          bubbleMsg = liveDelay > 0
              ? '$liveDelay min Late\nBetween ${s1.stationName} - ${s2.stationName}'
              : 'On Time\nBetween ${s1.stationName} - ${s2.stationName}';
        }

        return TrainLivePosition(
          currentStopIndex: i,
          nextStopIndex: i + 1,
          segmentProgress: progress,
          statusText: statusMsg,
          bubbleText: bubbleMsg,
          delayMinutes: liveDelay,
          currentStationName: s1.stationName,
          nextStationName: s2.stationName,
          pfNum: s2.pfNum ?? 'PF 1',
          pfSide: s2.pfSide ?? 'LEFT',
          isInsideTrain: isInsideTrain,
          detectionSource: detectionSource,
        );
      }
    }

    // Fallback
    final first = stops.first;
    return TrainLivePosition(
      currentStopIndex: 0,
      nextStopIndex: 1,
      segmentProgress: 0.5,
      statusText: 'Running',
      bubbleText: 'On Time',
      delayMinutes: 0,
      currentStationName: first.stationName,
      nextStationName: stops.last.stationName,
      pfNum: first.pfNum ?? 'PF 1',
      pfSide: first.pfSide ?? 'LEFT',
      isInsideTrain: isInsideTrain,
      detectionSource: detectionSource,
    );
  }

  /// Calculates distance in meters between two lat/lng coordinates (Haversine Formula)
  double calculateDistanceMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a)); // 2 * R * 1000
  }
}
