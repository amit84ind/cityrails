import 'package:flutter/material.dart';
import '../theme/tiranga_theme.dart';
import '../widgets/tiranga_app_bar.dart';

class BusExpressScreen extends StatelessWidget {
  final String category;

  const BusExpressScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: TirangaAppBar(
        title: category.toUpperCase(),
        subtitle: _getSubtitle(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(_getIcon(), color: TirangaTheme.saffron, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _getSubtitle(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'POPULAR ROUTES & TIMINGS',
            style: TextStyle(color: TirangaTheme.saffron, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),

          if (category.toLowerCase() == 'bus') ...[
            _buildRouteCard('BEST Route 351', 'Mumbai Central ➔ Bandra Bus Station', 'Via Dadar TT, Mahim', 'Every 10 Mins'),
            _buildRouteCard('BEST Route A-115', 'CSMT ➔ Nariman Point AC', 'Via Churchgate, Mantralaya', 'Every 6 Mins'),
            _buildRouteCard('NMMT Route 125', 'Borivali East ➔ Kharghar / Panvel', 'Via Ghodbunder Road, Thane', 'Every 20 Mins'),
            _buildRouteCard('TMT Route 65', 'Thane Station ➔ Borivali Station', 'Via Ghodbunder Road', 'Every 15 Mins'),
          ] else if (category.toLowerCase() == 'express') ...[
            _buildRouteCard('12123 Deccan Queen', 'CSMT ➔ Pune Junction', 'Dep: 05:10 PM | Arr: 08:25 PM', 'Platform 8 CSMT'),
            _buildRouteCard('12951 Rajdhani Express', 'Mumbai Central ➔ New Delhi', 'Dep: 05:00 PM | Arr: 08:32 AM', 'Platform 1 MMCT'),
            _buildRouteCard('12137 Punjab Mail', 'CSMT ➔ Firozpur Cantt', 'Dep: 07:35 PM | Arr: 05:10 AM', 'Platform 18 CSMT'),
            _buildRouteCard('12289 Nagpur Duronto', 'CSMT ➔ Nagpur Junction', 'Dep: 08:15 PM | Arr: 07:20 AM', 'Platform 16 CSMT'),
          ] else if (category.toLowerCase() == 'msrtc') ...[
            _buildRouteCard('Shivneri AC Bus', 'Dadarp / Thane ➔ Pune Station', 'Via Mumbai-Pune Expressway', 'Every 15 Mins'),
            _buildRouteCard('MSRTC Express', 'Thane Bus Stand ➔ Nashik CBS', 'Via Kasara Ghat', 'Every 30 Mins'),
            _buildRouteCard('MSRTC Semi-Luxury', 'Panvel Stand ➔ Alibaug', 'Via Pen', 'Every 20 Mins'),
          ] else ...[
            _buildRouteCard('Gorai Ferry', 'Gorai Jetty ➔ EsselWorld / Gorai Beach', 'Water Ferry Boat', 'Every 15 Mins'),
            _buildRouteCard('Gateway Ferry', 'Gateway of India ➔ Elephanta Caves', 'Tourist Passenger Boat', 'Hourly 09:00 AM - 03:00 PM'),
          ],
        ],
      ),
    );
  }

  String _getSubtitle() {
    switch (category.toLowerCase()) {
      case 'bus':
        return 'BEST, NMMT, TMT Bus Routes & Schedules';
      case 'express':
        return 'Indian Railways Express / Mail Trains';
      case 'msrtc':
        return 'MSRTC ST Bus & Shivneri Timings';
      default:
        return 'Mumbai Ferry & Water Taxi Routes';
    }
  }

  IconData _getIcon() {
    switch (category.toLowerCase()) {
      case 'bus':
      case 'msrtc':
        return Icons.directions_bus;
      case 'express':
        return Icons.train;
      default:
        return Icons.directions_boat;
    }
  }

  Widget _buildRouteCard(String name, String route, String details, String frequency) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(frequency, style: const TextStyle(color: TirangaTheme.saffron, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text(route, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(details, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
