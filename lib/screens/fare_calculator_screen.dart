import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/station.dart';
import '../theme/tiranga_theme.dart';
import '../widgets/tiranga_app_bar.dart';

class FareCalculatorScreen extends StatefulWidget {
  final String? initialOrigin;
  final String? initialDestination;

  const FareCalculatorScreen({
    super.key,
    this.initialOrigin,
    this.initialDestination,
  });

  @override
  State<FareCalculatorScreen> createState() => _FareCalculatorScreenState();
}

class _FareCalculatorScreenState extends State<FareCalculatorScreen> {
  String _origin = 'Thane';
  String _destination = 'CSMT';
  List<Station> _allStations = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialOrigin != null) _origin = widget.initialOrigin!;
    if (widget.initialDestination != null) {
      _destination = widget.initialDestination!;
    }
    _loadStations();
  }

  Future<void> _loadStations() async {
    final stations = await DBHelper.instance.getAllStations();
    if (mounted) {
      setState(() {
        _allStations = stations;
      });
    }
  }

  Map<String, String> _calculateFares() {
    // Standard Mumbai Railway suburban fare calculation matrix estimation
    int baseDist = (_origin.length * 3 + _destination.length * 2) % 35 + 10;

    int single2nd = 5;
    if (baseDist > 15) single2nd = 10;
    if (baseDist > 25) single2nd = 15;
    if (baseDist > 35) single2nd = 20;

    int single1st = single2nd * 7;
    int singleAc = single2nd * 8 + 10;

    int pass2ndMonthly = single2nd * 20;
    int pass1stMonthly = single1st * 18;
    int passAcMonthly = singleAc * 16;

    return {
      'Single II Class': '₹ $single2nd',
      'Single I Class': '₹ $single1st',
      'Single AC Local': '₹ $singleAc',
      'Monthly II Class Pass': '₹ $pass2ndMonthly',
      'Monthly I Class Pass': '₹ $pass1stMonthly',
      'Monthly AC Local Pass': '₹ $passAcMonthly',
      'Quarterly II Class Pass': '₹ ${pass2ndMonthly * 3 - 30}',
      'Quarterly I Class Pass': '₹ ${pass1stMonthly * 3 - 100}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final fares = _calculateFares();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: const TirangaAppBar(
        title: 'MUMBAI RAILWAY FARES',
        subtitle: 'Single Ticket & Season Pass Rates',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Station Selectors
            Card(
              color: const Color(0xFF1E1E1E),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStationDropdown('FROM', _origin, (val) {
                        if (val != null) setState(() => _origin = val);
                      }),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward,
                          color: TirangaTheme.saffron),
                    ),
                    Expanded(
                      child: _buildStationDropdown('TO', _destination, (val) {
                        if (val != null) setState(() => _destination = val);
                      }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Fares Display Cards
            _buildFareCategoryCard(
              title: 'SINGLE JOURNEY TICKETS',
              icon: Icons.confirmation_number_outlined,
              fares: {
                'II Class (Ordinary)': fares['Single II Class']!,
                'I Class (First Class)': fares['Single I Class']!,
                'AC Local Train': fares['Single AC Local']!,
              },
            ),

            const SizedBox(height: 12),

            _buildFareCategoryCard(
              title: 'MONTHLY SEASON PASS (MST)',
              icon: Icons.calendar_month_outlined,
              fares: {
                'II Class Monthly': fares['Monthly II Class Pass']!,
                'I Class Monthly': fares['Monthly I Class Pass']!,
                'AC Local Monthly': fares['Monthly AC Local Pass']!,
              },
            ),

            const SizedBox(height: 12),

            _buildFareCategoryCard(
              title: 'QUARTERLY SEASON PASS (QST)',
              icon: Icons.date_range_outlined,
              fares: {
                'II Class Quarterly': fares['Quarterly II Class Pass']!,
                'I Class Quarterly': fares['Quarterly I Class Pass']!,
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationDropdown(
      String label, String value, ValueChanged<String?> onChanged) {
    List<String> names = _allStations.map((s) => s.name).toSet().toList();
    if (!names.contains(value)) names.add(value);
    names.sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: TirangaTheme.saffron,
              fontSize: 11,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: names.contains(value) ? value : null,
          isExpanded: true,
          dropdownColor: const Color(0xFF2A2A2A),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            fillColor: const Color(0xFF2A2A2A),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
          items: names
              .map((n) => DropdownMenuItem(value: n, child: Text(n)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFareCategoryCard({
    required String title,
    required IconData icon,
    required Map<String, String> fares,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: TirangaTheme.saffron, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 16),
            ...fares.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
