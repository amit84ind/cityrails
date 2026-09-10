import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/station.dart';
import '../theme/tiranga_theme.dart';
import '../widgets/tiranga_app_bar.dart';
import 'station_trains_screen.dart';
import 'a_to_b_screen.dart';
import 'fare_calculator_screen.dart';

class LocalTrainScreen extends StatefulWidget {
  final int initialTabIndex;

  const LocalTrainScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<LocalTrainScreen> createState() => _LocalTrainScreenState();
}

class _LocalTrainScreenState extends State<LocalTrainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Station> _stations = [];
  List<Station> _filteredStations = [];
  String _selectedLineFilter = 'All'; // All, Western, Central, Harbour, Trans-Harbour, Uran
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _loadStations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadStations() async {
    final stations =
        await DBHelper.instance.getAllStations(line: _selectedLineFilter);
    if (mounted) {
      setState(() {
        _stations = stations;
        _applySearchFilter();
      });
    }
  }

  void _applySearchFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStations = List.from(_stations);
      } else {
        _filteredStations = _stations
            .where((s) => s.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  String _getUpLabel(String line) {
    switch (line) {
      case 'Western':
        return 'Churchgate (UP)';
      case 'Central':
        return 'CSMT / Dadar (UP)';
      case 'Harbour':
        return 'CSMT / Goregaon (UP)';
      case 'Trans-Harbour':
        return 'Thane (UP)';
      case 'Uran':
        return 'Nerul / Belapur (UP)';
      default:
        return 'UP Direction';
    }
  }

  String _getDownLabel(String line) {
    switch (line) {
      case 'Western':
        return 'Virar / Dahanu (DN)';
      case 'Central':
        return 'Kasara / Karjat (DN)';
      case 'Harbour':
        return 'Panvel (DN)';
      case 'Trans-Harbour':
        return 'Vashi / Panvel (DN)';
      case 'Uran':
        return 'Uran (DN)';
      default:
        return 'DOWN Direction';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: TirangaAppBar(
        title: 'm-Indicator - Mumbai',
        subtitle: 'LOCAL • METRO • MONO TRAIN SEARCH',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: TirangaTheme.saffron,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'STATION'),
            Tab(text: 'A to B'),
            Tab(text: 'FARE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStationTab(),
          const AToBScreen(),
          const FareCalculatorScreen(),
        ],
      ),
    );
  }

  Widget _buildStationTab() {
    return Column(
      children: [
        // Search & Line Selection Header (Matching Screenshot 5!)
        Container(
          color: const Color(0xFF1E1E1E),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              // Search Input Box: "You are at?"
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (_) => _applySearchFilter(),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'You are at?',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: TirangaTheme.saffron),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _applySearchFilter();
                          },
                        ),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Dark Navy Sub-Navigation Bar (Matching Screenshot 5!)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B263B), // Dark Navy blue bar
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'All',
                      'Western',
                      'Central',
                      'Harbour',
                      'Trans-Harbour',
                      'Uran'
                    ].map((lineName) {
                      bool isSelected = _selectedLineFilter == lineName;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedLineFilter = lineName;
                            });
                            _loadStations();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? TirangaTheme.navyBlue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected
                                    ? TirangaTheme.saffron
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              lineName.toUpperCase(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade300,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Stations List
        Expanded(
          child: _filteredStations.isEmpty
              ? const Center(
                  child: Text('No matching stations found',
                      style: TextStyle(color: Colors.white70)),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  itemCount: _filteredStations.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final stn = _filteredStations[index];
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Station Header Tile
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StationTrainsScreen(
                                      stationName: stn.name,
                                      line: stn.line,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  // White Circle Dot
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      stn.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Line Badge Badge Tag on far right (Exact match to image 5!)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getLineBadgeColor(stn.line),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      _getLineBadgeText(stn.line),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // TOWARDS UP & TOWARDS DOWN Buttons (Image 5 & User Spec!)
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StationTrainsScreen(
                                            stationName: stn.name,
                                            line: stn.line,
                                            initialDirection: 'UP',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2C2C2C),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: TirangaTheme.saffron),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.arrow_upward,
                                              color: TirangaTheme.saffron,
                                              size: 12),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'UP: ${_getUpLabel(stn.line)}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StationTrainsScreen(
                                            stationName: stn.name,
                                            line: stn.line,
                                            initialDirection: 'DN',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2C2C2C),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: Colors.greenAccent),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.arrow_downward,
                                              color: Colors.greenAccent,
                                              size: 12),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'DN: ${_getDownLabel(stn.line)}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getLineBadgeColor(String line) {
    switch (line) {
      case 'Western':
        return const Color(0xFF1E88E5); // Blue 'W'
      case 'Central':
        return const Color(0xFF3949AB); // Dark Blue 'C'
      case 'Harbour':
        return const Color(0xFF00897B); // Teal 'H'
      case 'Trans-Harbour':
        return const Color(0xFF8E24AA); // Purple 'T'
      case 'Uran':
        return const Color(0xFFFB8C00); // Orange 'U'
      default:
        return Colors.grey;
    }
  }

  String _getLineBadgeText(String line) {
    switch (line) {
      case 'Western':
        return 'W';
      case 'Central':
        return 'C';
      case 'Harbour':
        return 'H';
      case 'Trans-Harbour':
        return 'T';
      case 'Uran':
        return 'U';
      default:
        return 'LINE';
    }
  }
}
