import 'package:flutter/material.dart';
import '../theme/tiranga_theme.dart';
import '../widgets/tiranga_app_bar.dart';

class RailwayMapScreen extends StatelessWidget {
  const RailwayMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: const TirangaAppBar(
        title: 'MUMBAI RAILWAY MAP',
        subtitle: 'Suburban Network Route Diagram',
      ),
      body: InteractiveViewer(
        minScale: 0.8,
        maxScale: 4.0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Network Line Legend
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MUMBAI SUBURBAN NETWORK LINES',
                          style: TextStyle(
                            color: TirangaTheme.saffron,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildLineLegendRow('Western Line', Colors.pinkAccent,
                            'Churchgate ➔ Dahanu Road'),
                        _buildLineLegendRow('Central Line', Colors.blueAccent,
                            'CSMT ➔ Kalyan ➔ Kasara / Khopoli'),
                        _buildLineLegendRow('Harbour Line', Colors.tealAccent,
                            'CSMT ➔ Panvel / Goregaon'),
                        _buildLineLegendRow('Trans-Harbour Line',
                            Colors.purpleAccent, 'Thane ➔ Vashi / Panvel'),
                        _buildLineLegendRow('Uran Line', Colors.orangeAccent,
                            'Nerul / Belapur ➔ Uran'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Route Diagram Canvas / Illustration
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.map,
                            size: 64, color: TirangaTheme.saffron),
                        const SizedBox(height: 12),
                        const Text(
                          'MUMBAI SUBURBAN NETWORK MAP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pinch to zoom in or double-tap to inspect interchange hubs:\nDADAR, KURLA, THANE, KALYAN, ANDHERI, VASHI',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 20),

                        // Visual Representation of Mumbai Railway Junctions
                        _buildMapNode('VIRAR / DAHANU', Colors.pinkAccent),
                        _buildMapLine(Colors.pinkAccent),
                        _buildMapNode('BORIVALI', Colors.pinkAccent),
                        _buildMapLine(Colors.pinkAccent),
                        _buildMapNode('ANDHERI (Metro L1 Interchange)', Colors.pinkAccent),
                        _buildMapLine(Colors.pinkAccent),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMapNode('DADAR (W / C Hub)', Colors.amber),
                          ],
                        ),
                        _buildMapLine(Colors.blueAccent),
                        _buildMapNode('KURLA (Central / Harbour)', Colors.amber),
                        _buildMapLine(Colors.blueAccent),
                        _buildMapNode('THANE (Central / Trans-Harbour)', Colors.amber),
                        _buildMapLine(Colors.blueAccent),
                        _buildMapNode('KALYAN (Kasara / Karjat Split)', Colors.blueAccent),
                        _buildMapLine(Colors.blueAccent),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMapNode('KASARA', Colors.blueAccent),
                            _buildMapNode('KHOPOLI', Colors.blueAccent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineLegendRow(String name, Color color, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '($route)',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapNode(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMapLine(Color color) {
    return Container(
      width: 3,
      height: 24,
      color: color,
    );
  }
}
