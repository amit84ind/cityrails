import 'package:flutter/material.dart';
import '../models/train.dart';
import '../theme/tiranga_theme.dart';

class TrainCard extends StatelessWidget {
  final Train train;
  final VoidCallback onTap;

  const TrainCard({
    super.key,
    required this.train,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color typeColor = train.isFast
        ? TirangaTheme.fastTrainRed
        : TirangaTheme.slowTrainGreen;
    if (train.isAc) {
      typeColor = TirangaTheme.acTrainPurple;
    }

    String typeBadgeText = train.isFast ? 'F' : 'S';
    if (train.isAc) typeBadgeText = 'AC';

    String depTime = train.stationDepartureTime ?? train.startTime;
    
    // Format 24-hr time to 12-hr AM/PM format if needed
    String formattedTime = _formatToAmPm(depTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Color Stripe for Slow / Fast / AC
              Container(
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),

              // Time & Train Basic Specs
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${train.destination.toUpperCase()}  $typeBadgeText',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${train.trainNo} : ${train.origin} - ${train.destination}',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (train.currentStatus != null)
                      Text(
                        train.currentStatus!,
                        style: TextStyle(
                          color: (train.delayMinutes > 0)
                              ? Colors.orangeAccent
                              : Colors.lightGreenAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Platform Number & Side Info Box
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PF',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      train.platformNumber ?? '1',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (train.platformSide != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        train.platformSide!.toUpperCase(),
                        style: const TextStyle(
                          color: TirangaTheme.saffron,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatToAmPm(String time24) {
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
}
