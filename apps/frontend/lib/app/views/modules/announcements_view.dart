import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';

class AnnouncementsView extends GetView<DashboardController> {
  const AnnouncementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> announcements = <Map<String, String>>[
      <String, String>{
        'title': 'Monsoon safety guidelines on highways',
        'date': '2026-07-12',
        'desc': 'All drivers are requested to maintain speeds under 60km/h on regional highways during heavy downpours. Double distance parameters behind containers.',
      },
      <String, String>{
        'title': 'Depot 04 Toll updates',
        'date': '2026-07-10',
        'desc': 'Fastag configurations for MH registration trucks have been successfully updated in storage. Check your terminal wallet balance before leaving.',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: announcements.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(child: Text(announcements[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      Text(announcements[index]['date']!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(announcements[index]['desc']!, style: TextStyle(height: 1.4, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
