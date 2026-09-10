import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/station.dart';
import '../theme/tiranga_theme.dart';
import '../widgets/tiranga_app_bar.dart';
import 'train_running_status_screen.dart';

class AToBScreen extends StatefulWidget {
  final String? initialOrigin;
  final String? initialDestination;

  const AToBScreen({
    super.key,
    this.initialOrigin,
    this.initialDestination,
  });

  @override
  State<AToBScreen> createState() => _AToBScreenState();
}

class _AToBScreenState extends State<AToBScreen> {
  String _origin = 'Thane';
  String _destination = 'Vashi';
  List<Station> _allStations = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialOrigin != null) _origin = widget.initialOrigin!;
    if (widget.initialDestination != null) {
      _destination = widget.initialDestination!;
    }
    _loadStations();
    _performSearch();
  }

  Future<void> _loadStations() async {
    final stations = await DBHelper.instance.getAllStations();
    if (mounted) {
      setState(() {
        _allStations = stations;
      });
    }
  }

  Future<void> _performSearch() async {
    if (_origin.isEmpty || _destination.isEmpty || _origin == _destination) {
      return;
    }
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final results = await DBHelper.instance.searchABTrains(_origin, _destination);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  void _swapStations() {
    setState(() {
      final temp = _origin;
      _origin = _destination;
      _destination = temp;
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: const TirangaAppBar(
        title: 'A TO B TRAIN SEARCH',
        subtitle: 'Find Direct Trains Between Any Two Stations',
      ),
      body: Column(
        children: [
          // Station Selection Card
          Card(
            margin: const EdgeInsets.all(12),
            color: const Color(0xFF1E1E1E),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStationDropdown(
                          label: 'FROM STATION',
                          value: _origin,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _origin = val);
                              _performSearch();
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz,
                            color: TirangaTheme.saffron, size: 28),
                        onPressed: _swapStations,
                        tooltip: 'Swap Stations',
                      ),
                      Expanded(
                        child: _buildStationDropdown(
                          label: 'TO STATION',
                          value: _destination,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _destination = val);
                              _performSearch();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TirangaTheme.saffron,
                      ),
                      onPressed: _performSearch,
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text(
                        'SEARCH TRAINS',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: TirangaTheme.saffron))
                : !_hasSearched
                    ? const Center(
                        child: Text('Select Origin and Destination to Search',
                            style: TextStyle(color: Colors.white70)))
                    : _searchResults.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No direct trains found between $_origin and $_destination.\nTry searching connecting trains or changing direction.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final item = _searchResults[index];
                              return _buildTrainResultCard(item);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    List<String> stationNames =
        _allStations.map((s) => s.name).toSet().toList();
    if (!stationNames.contains(value) && value.isNotEmpty) {
      stationNames.add(value);
    }
    stationNames.sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: TirangaTheme.saffron,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: stationNames.contains(value) ? value : null,
          isExpanded: true,
          dropdownColor: const Color(0xFF2A2A2A),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            fillColor: const Color(0xFF2A2A2A),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
          items: stationNames.map((stn) {
            return DropdownMenuItem(
              value: stn,
              child: Text(
                stn,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTrainResultCard(Map<String, dynamic> item) {
    String trainNo = item['train_no'] ?? '';
    String originTime = item['origin_time'] ?? '';
    String destTime = item['dest_time'] ?? '';
    bool isFast = (item['is_fast'] ?? 0) == 1;
    bool isAc = (item['is_ac'] ?? 0) == 1;

    int origMins = item['origin_mins'] ?? 0;
    int destMins = item['dest_mins'] ?? 0;
    int durationMins = (destMins - origMins + 1440) % 1440;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainRunningStatusScreen(
                trainNo: trainNo,
                initialStationName: _origin,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Times Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        originTime,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        ' ➔ ',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      Text(
                        destTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$durationMins Mins Journey • Train $trainNo',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Badge Fast / AC
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAc
                      ? TirangaTheme.acTrainPurple
                      : (isFast
                          ? TirangaTheme.fastTrainRed
                          : TirangaTheme.slowTrainGreen),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isAc ? 'AC LOCAL' : (isFast ? 'FAST' : 'SLOW'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
