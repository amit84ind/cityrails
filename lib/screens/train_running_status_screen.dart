import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/train.dart';
import '../models/train_stop.dart';
import '../database/db_helper.dart';
import '../services/live_tracking_service.dart';
import '../theme/tiranga_theme.dart';
import '../widgets/tiranga_app_bar.dart';

class TrainRunningStatusScreen extends StatefulWidget {
  final String trainNo;
  final String? initialStationName;

  const TrainRunningStatusScreen({
    super.key,
    required this.trainNo,
    this.initialStationName,
  });

  @override
  State<TrainRunningStatusScreen> createState() =>
      _TrainRunningStatusScreenState();
}

class _TrainRunningStatusScreenState extends State<TrainRunningStatusScreen> {
  Train? _train;
  bool _isLoading = true;
  bool _isInsideTrain = false;
  Position? _currentPosition;
  Timer? _refreshTimer;
  TrainLivePosition? _livePosition;

  @override
  void initState() {
    super.initState();
    _isInsideTrain = LiveTrackingService.instance.isInsideTrain;
    _loadTrainDetails();
    _initGps();

    // Auto-refresh running status every 15 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) _updateLiveStatus();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initGps() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        if (mounted) {
          setState(() {
            _currentPosition = pos;
          });
          _updateLiveStatus();
        }
      }
    } catch (_) {}
  }

  Future<void> _loadTrainDetails() async {
    setState(() => _isLoading = true);
    final train = await DBHelper.instance.getTrainWithRoute(widget.trainNo);
    if (mounted) {
      setState(() {
        _train = train;
        _isLoading = false;
      });
      _updateLiveStatus();
    }
  }

  void _updateLiveStatus() {
    if (_train == null || _train!.stops == null) return;
    final pos = LiveTrackingService.instance.calculateLivePosition(
      _train!,
      deviceLocation: _currentPosition,
    );
    if (mounted) {
      setState(() {
        _livePosition = pos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: TirangaAppBar(
        title: _train != null
            ? '${_train!.origin} - ${_train!.destination} TRAIN'
            : 'TRAIN STATUS',
        subtitle: _train != null
            ? 'Train No. ${_train!.trainNo} (${_train!.isFast ? "FAST" : "SLOW"}${_train!.isAc ? " AC" : ""})'
            : null,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TirangaTheme.saffron))
          : _train == null || _train!.stops == null || _train!.stops!.isEmpty
              ? const Center(
                  child: Text('Train timetable details not found.',
                      style: TextStyle(color: Colors.white)))
              : Column(
                  children: [
                    // Top Banner: "Are you inside this train? NO / YES"
                    _buildInsideTrainBanner(),

                    // Scheduled vs Expected Table Header
                    _buildTableHeader(),

                    // Vertical Station Timeline with Running Train Icon & Speech Bubble
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _updateLiveStatus();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: _train!.stops!.length,
                          itemBuilder: (context, index) {
                            final stop = _train!.stops![index];
                            return _buildTimelineItem(index, stop);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TirangaTheme.saffron,
        onPressed: () {
          _updateLiveStatus();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Train live running position updated!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildInsideTrainBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF8B0000), // m-indicator dark red banner style
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Are you inside this train ?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Row(
            children: [
              Text(
                _isInsideTrain ? 'YES' : 'NO',
                style: TextStyle(
                  color: _isInsideTrain
                      ? Colors.greenAccent
                      : Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _isInsideTrain,
                activeColor: Colors.greenAccent,
                inactiveThumbColor: Colors.grey,
                onChanged: (val) {
                  setState(() {
                    _isInsideTrain = val;
                    LiveTrackingService.instance.isInsideTrain = val;
                  });
                  _updateLiveStatus();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SCHEDULED',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'STATION',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'EXPECTED',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(int index, TrainStop stop) {
    bool isCurrentSegment = _livePosition != null &&
        index == _livePosition!.currentStopIndex;
    bool isPassed = _livePosition != null && index < _livePosition!.currentStopIndex;
    bool isTargetStation =
        widget.initialStationName != null && stop.stationName == widget.initialStationName;

    // Time calculations
    String scheduledTime = _formatTime(stop.departureTime);
    int expectedMins =
        stop.departureMinutes + (_livePosition?.delayMinutes ?? 0);
    String expectedTime = _formatMinutesToAmPm(expectedMins);

    return Column(
      children: [
        // Station Row
        Container(
          color: isTargetStation
              ? const Color(0xFF333333)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Scheduled Departure Time Column
              SizedBox(
                width: 75,
                child: Text(
                  scheduledTime,
                  style: TextStyle(
                    color: isPassed
                        ? Colors.grey
                        : (isTargetStation ? Colors.greenAccent : Colors.lightGreenAccent),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Vertical Timeline Track Node
              SizedBox(
                width: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Vertical Line Segment
                    Container(
                      width: 3,
                      height: 48,
                      color: isPassed ? Colors.grey.shade700 : Colors.white,
                    ),
                    // Station Circle Node
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isPassed
                            ? Colors.grey.shade600
                            : (isCurrentSegment ? TirangaTheme.saffron : Colors.white),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrentSegment ? Colors.white : Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Station Name & Platform info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.stationName,
                      style: TextStyle(
                        color: isPassed
                            ? Colors.grey
                            : (isTargetStation
                                ? Colors.greenAccent
                                : Colors.white),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stop.pfNum ?? "PF1"} ${stop.pfSide ?? "LEFT"}',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Expected Arrival Time Column
              SizedBox(
                width: 70,
                child: Text(
                  expectedTime,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: (_livePosition?.delayMinutes ?? 0) > 0
                        ? Colors.redAccent
                        : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Running Train Speech Bubble Banner between active station stops!
        if (isCurrentSegment && _livePosition != null)
          _buildTrainRunningBubbleOverlay(_livePosition!),
      ],
    );
  }

  Widget _buildTrainRunningBubbleOverlay(TrainLivePosition pos) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50), // m-indicator green status speech bubble
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Live Animated Train Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.train,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Status Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pos.bubbleText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tracked via ${pos.detectionSource}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length < 2) return time24;
      int hh = int.parse(parts[0]);
      int mm = int.parse(parts[1]);
      String period = hh >= 12 ? 'PM' : 'AM';
      int hh12 = hh % 12;
      if (hh12 == 0) hh12 = 12;
      return '${hh12.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time24;
    }
  }

  String _formatMinutesToAmPm(int mins) {
    int normalized = (mins + 1440) % 1440;
    int hh = normalized ~/ 60;
    int mm = normalized % 60;
    return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
  }
}
