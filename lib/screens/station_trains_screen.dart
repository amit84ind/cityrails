import 'dart:async';
import 'package:flutter/material.dart';
import '../models/train.dart';
import '../database/db_helper.dart';
import '../theme/tiranga_theme.dart';
import '../widgets/tiranga_app_bar.dart';
import '../widgets/train_card.dart';
import 'train_running_status_screen.dart';

class StationTrainsScreen extends StatefulWidget {
  final String stationName;
  final String line;
  final String? initialDirection; // 'UP', 'DN', or null

  const StationTrainsScreen({
    super.key,
    required this.stationName,
    required this.line,
    this.initialDirection,
  });

  @override
  State<StationTrainsScreen> createState() => _StationTrainsScreenState();
}

class _StationTrainsScreenState extends State<StationTrainsScreen> {
  List<Train> _trains = [];
  bool _isLoading = true;
  String _activeFilter = 'ALL'; // ALL, SLOW, FAST, AC
  String _activeDirection = 'ALL'; // ALL, UP, DN
  bool _isFavorite = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialDirection != null) {
      _activeDirection = widget.initialDirection!;
    }
    _checkFavorite();
    _loadTrains();

    // Auto refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadTrains();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkFavorite() async {
    final favorites = await DBHelper.instance.getFavoriteStations();
    if (mounted) {
      setState(() {
        _isFavorite = favorites.contains(widget.stationName);
      });
    }
  }

  Future<void> _loadTrains() async {
    setState(() => _isLoading = true);
    final trains = await DBHelper.instance.getTrainsAtStation(
      widget.stationName,
      filter: _activeFilter,
      direction: _activeDirection,
    );
    if (mounted) {
      setState(() {
        _trains = trains;
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite() async {
    await DBHelper.instance
        .toggleFavoriteStation(widget.stationName, widget.line);
    _checkFavorite();
  }

  String _getDirectionLabel(String dir) {
    if (widget.line == 'Western') {
      return dir == 'UP' ? 'UP (Churchgate)' : 'DOWN (Virar/Dahanu)';
    } else if (widget.line == 'Central') {
      return dir == 'UP' ? 'UP (CSMT/Dadar)' : 'DOWN (Kasara/Karjat)';
    } else if (widget.line == 'Harbour') {
      return dir == 'UP' ? 'UP (CSMT/Goregaon)' : 'DOWN (Panvel)';
    } else {
      return dir == 'UP' ? 'UP Direction' : 'DOWN Direction';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: TirangaAppBar(
        title: widget.stationName.toUpperCase(),
        subtitle: '${widget.line} Line Schedules',
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.amber : Colors.white,
            ),
            onPressed: _toggleFavorite,
            tooltip: 'Favorite Station',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrains,
            tooltip: 'Refresh Schedules',
          ),
        ],
      ),
      body: Column(
        children: [
          // Direction Selector Header (ALL | UP | DOWN)
          _buildDirectionHeader(),

          // Live Train List
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: TirangaTheme.saffron))
                : _trains.isEmpty
                    ? Center(
                        child: Text(
                          'No trains found at ${widget.stationName} for filter $_activeFilter ($_activeDirection)',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTrains,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _trains.length,
                          itemBuilder: (context, index) {
                            final train = _trains[index];
                            return TrainCard(
                              train: train,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TrainRunningStatusScreen(
                                      trainNo: train.trainNo,
                                      initialStationName: widget.stationName,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),

          // Bottom Filter Tabs Bar (SLOW, FAST, ALL, AC)
          _buildBottomFilterBar(),
        ],
      ),
    );
  }

  Widget _buildDirectionHeader() {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        children: [
          _buildDirectionTab('ALL', 'ALL'),
          const SizedBox(width: 6),
          _buildDirectionTab('UP', _getDirectionLabel('UP')),
          const SizedBox(width: 6),
          _buildDirectionTab('DN', _getDirectionLabel('DN')),
        ],
      ),
    );
  }

  Widget _buildDirectionTab(String dirKey, String label) {
    bool isSelected = _activeDirection == dirKey;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (_activeDirection != dirKey) {
            setState(() {
              _activeDirection = dirKey;
            });
            _loadTrains();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? TirangaTheme.saffronDark : const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? TirangaTheme.saffron : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade300,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomFilterBar() {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFilterButton('SLOW', 'SLOW'),
            _buildFilterButton('FAST', 'FAST'),
            _buildFilterButton('ALL', 'ALL'),
            _buildFilterButton('AC', 'AC'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String filterKey) {
    bool isSelected = _activeFilter == filterKey;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (_activeFilter != filterKey) {
            setState(() {
              _activeFilter = filterKey;
            });
            _loadTrains();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? TirangaTheme.navyBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? TirangaTheme.saffron : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade400,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
