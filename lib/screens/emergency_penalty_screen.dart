import 'package:flutter/material.dart';
import '../theme/tiranga_theme.dart';
import '../widgets/tiranga_app_bar.dart';

class EmergencyPenaltyScreen extends StatelessWidget {
  const EmergencyPenaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: const TirangaAppBar(
        title: 'EMERGENCY & PENALTY',
        subtitle: 'Railway Helplines & Traffic Fine Chart',
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Emergency Contacts Section
          const Text(
            'RAILWAY EMERGENCY HELPLINES',
            style: TextStyle(
              color: TirangaTheme.saffron,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          _buildHelplineCard('Railway Emergency Helpline', '139', Icons.phone_in_talk, Colors.redAccent),
          _buildHelplineCard('Railway Protection Force (RPF)', '182', Icons.security, Colors.orangeAccent),
          _buildHelplineCard('Government Railway Police (GRP)', '1512', Icons.local_police, Colors.blueAccent),
          _buildHelplineCard('Women Safety Helpline', '1091', Icons.shield, Colors.pinkAccent),
          _buildHelplineCard('Medical First Aid (Station)', '139', Icons.medical_services, Colors.greenAccent),

          const SizedBox(height: 20),

          // Railway Fine & Penalty Chart Section
          const Text(
            'RAILWAY OFFENCES & PENALTY RULES',
            style: TextStyle(
              color: TirangaTheme.saffron,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          _buildPenaltyCard('Ticketless Travel', '₹ 250 + Single Fare', 'Section 138 - Traveling without valid ticket or pass'),
          _buildPenaltyCard('Traveling in Ladies Coach', '₹ 500 Fine', 'Section 162 - Male passenger entering ladies compartment'),
          _buildPenaltyCard('Footboard & Roof Riding', '₹ 500 Fine / 3 Mths Jail', 'Section 156 - Riding on footboard or roof of train'),
          _buildPenaltyCard('Unauthorised Hawking', '₹ 1,000 Fine', 'Section 144 - Selling goods inside train/station premises'),
          _buildPenaltyCard('Littering Railway Premises', '₹ 500 Fine', 'Section 145 - Throwing trash on tracks or platform'),
        ],
      ),
    );
  }

  Widget _buildHelplineCard(String title, String number, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('Call $number', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          child: Text('CALL $number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildPenaltyCard(String title, String fine, String description) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), border: Border.all(color: Colors.redAccent), borderRadius: BorderRadius.circular(4)),
              child: Text(fine, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
