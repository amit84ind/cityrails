import 'package:flutter/material.dart';
import '../theme/tiranga_theme.dart';
import 'local_train_screen.dart';
import 'train_chat_screen.dart';
import 'railway_map_screen.dart';
import 'emergency_penalty_screen.dart';
import 'metro_mono_screen.dart';
import 'bus_express_screen.dart';
import 'fare_calculator_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Column(
          children: [
            // Tiranga Top Color Strip
            SizedBox(
              height: 5,
              child: Row(
                children: [
                  Expanded(child: Container(color: TirangaTheme.saffron)),
                  Expanded(child: Container(color: TirangaTheme.white)),
                  Expanded(child: Container(color: TirangaTheme.green)),
                ],
              ),
            ),
            AppBar(
              backgroundColor: const Color(0xFF8B0000), // m-indicator header red style
              elevation: 2,
              title: const Row(
                children: [
                  Icon(Icons.directions_subway_rounded,
                      color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CITYRAILS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'Mumbai • Tiranga Edition',
                        style: TextStyle(
                          color: TirangaTheme.saffron,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergencyPenaltyScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shield_outlined,
                      color: Colors.white, size: 18),
                  label: const Text(
                    'HELPLINE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        children: [
          // Main 12-Icon Dashboard Grid (Exact replica of m-indicator screenshot 2!)
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.82,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _buildGridCard(
                context,
                title: 'Local',
                icon: Icons.train_rounded,
                iconColor: Colors.amber,
                badge: 'LIVE',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocalTrainScreen(),
                    ),
                  );
                },
              ),
              _buildGridCard(
                context,
                title: 'Bus',
                icon: Icons.directions_bus_rounded,
                iconColor: Colors.redAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const BusExpressScreen(category: 'Bus'),
                    ),
                  );
                },
              ),
              _buildGridCard(
                context,
                title: 'Express',
                icon: Icons.train_outlined,
                iconColor: Colors.blueAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const BusExpressScreen(category: 'Express'),
                    ),
                  );
                },
              ),
              _buildGridCard(
                context,
                title: 'MSRTC',
                icon: Icons.directions_bus_filled_rounded,
                iconColor: Colors.red.shade400,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const BusExpressScreen(category: 'MSRTC'),
                    ),
                  );
                },
              ),
              _buildGridCard(
                context,
                title: 'Train Chat',
                icon: Icons.chat_bubble_rounded,
                iconColor: Colors.amber.shade600,
                badge: 'NEW',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrainChatScreen(),
                    ),
                  );
                },
              ),
              _buildGridCard(
                context,
                title: 'Mono',
                icon: Icons.directions_railway_filled_rounded,
                iconColor: Colors.pinkAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MetroMonoScreen(title: 'Mumbai Monorail'),
                    ),
                  );
                },
              ),
              _buildGridCard(
                context,
                title: 'Metro',
                icon: Icons.subway_rounded,
                iconColor: Colors.lightBlueAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MetroMonoScreen(title: 'Mumbai Metro'),
                    ),
                  );
                },
              ),
              _buildGridCard(
                context,
                title: 'Auto',
                icon: Icons.electric_rickshaw_rounded,
                iconColor: Colors.amberAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FareCalculatorScreen(),
                    ),
                  );
                },
              ),
              _buildGridCard(
                context,
                title: 'Cab',
                icon: Icons.local_taxi_rounded,
                iconColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FareCalculatorScreen(),
                    ),
                  );
                },
              ),
              _buildGridCard(
                context,
                title: 'Ferry',
                icon: Icons.directions_boat_rounded,
                iconColor: Colors.cyanAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const BusExpressScreen(category: 'Ferry'),
                    ),
                  );
                },
              ),
              _buildGridCard(
                context,
                title: 'Jobs',
                icon: Icons.business_center_rounded,
                iconColor: Colors.grey.shade300,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Railway Recruitment & Official Notification board')),
                  );
                },
              ),
              _buildGridCard(
                context,
                title: 'Map',
                icon: Icons.map_rounded,
                iconColor: Colors.lightGreenAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RailwayMapScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // "OTHER" Section (Matching m-indicator screenshot 2!)
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'OTHER SERVICES',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),

          _buildOtherListTile(
            context,
            icon: Icons.museum_outlined,
            title: 'Mumbai Exhibitions & Events',
            onTap: () {},
          ),
          _buildOtherListTile(
            context,
            icon: Icons.theater_comedy_outlined,
            title: 'Natak - Marathi Hindi Gujarati Drama',
            onTap: () {},
          ),
          _buildOtherListTile(
            context,
            icon: Icons.gavel_outlined,
            title: 'Penalty Rules - Traffic & Railway Fines',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyPenaltyScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Icon(icon, color: iconColor, size: 36),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: TirangaTheme.saffron,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: TirangaTheme.saffron, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
