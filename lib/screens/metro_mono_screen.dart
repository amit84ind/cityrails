import 'package:flutter/material.dart';
import '../theme/tiranga_theme.dart';
import '../widgets/tiranga_app_bar.dart';

class MetroMonoScreen extends StatelessWidget {
  final String title;

  const MetroMonoScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    bool isMetro = title.toLowerCase().contains('metro');

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: TirangaAppBar(
        title: title.toUpperCase(),
        subtitle: isMetro ? 'Mumbai Metro Line 1, 2A, 7 & Aqua Line 3' : 'Chembur - Jacob Circle Monorail',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(isMetro ? Icons.subway : Icons.directions_railway,
                        color: TirangaTheme.saffron, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      isMetro ? 'MUMBAI METRO LINES' : 'MUMBAI MONORAIL',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isMetro
                      ? '• Line 1: Versova ➔ Andheri ➔ Ghatkopar (Frequency: 4 mins)\n'
                        '• Line 2A: Dahisar East ➔ Andheri West\n'
                        '• Line 7: Dahisar East ➔ Gundavali (WEH)\n'
                        '• Line 3: Aarey ➔ BKC ➔ Cuffe Parade'
                      : '• Route: Chembur ➔ Wadala ➔ Jacob Circle (Sat Rasta)\n'
                        '• Frequency: Every 15-20 minutes\n'
                        '• Operating Hours: 06:15 AM to 10:00 PM',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'STATION STOPS & FARES',
            style: TextStyle(color: TirangaTheme.saffron, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),

          if (isMetro) ...[
            _buildRouteTile('Versova', 'Ghatkopar', 'Versova - D.N. Nagar - Azad Nagar - Andheri - WEH - Chakala - Airport Road - Marol Naka - Saki Naka - Asalpha - Jagruti Nagar - Ghatkopar', '₹ 10 - ₹ 40'),
            _buildRouteTile('Dahisar East', 'Andheri West', 'Dahisar East - Anand Nagar - Kandarpada - Mandapeshwar - Magathane - Borivali West - Malad West - Lower Oshiwara - Andheri West', '₹ 10 - ₹ 30'),
            _buildRouteTile('Dahisar East', 'Gundavali', 'Dahisar East - Ovaripada - National Park - Bandongri - Kurar - Aarey - Goregaon East - Jogeshwari East - Gundavali', '₹ 10 - ₹ 30'),
          ] else ...[
            _buildRouteTile('Chembur', 'Jacob Circle', 'Chembur - VNP & RC Marg - Fertilizer Township - Bharat Petroleum - Mysore Colony - Bhakti Park - Wadala Depot - GTB Nagar - Antop Hill - Acharya Atre Nagar - Wadala Bridge - Mint Colony - Ambedkar Nagar - Naigaon - Lower Parel - Jacob Circle', '₹ 10 - ₹ 40'),
          ]
        ],
      ),
    );
  }

  Widget _buildRouteTile(String start, String end, String stations, String fare) {
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
                Text('$start ➔ $end', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(fare, style: const TextStyle(color: TirangaTheme.saffron, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            Text(stations, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.3)),
          ],
        ),
      ),
    );
  }
}
