import 'package:flutter/material.dart';
import 'package:safepath/features/voice_navigation/voice_navigation_service.dart';

class VoiceControlPanel extends StatelessWidget {
  final VoidCallback? onEmergency;
  const VoiceControlPanel({super.key, this.onEmergency});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await VoiceNavigationService().speak('Turn left - safe, well-lit route');
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Speak Guidance'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: onEmergency,
              icon: const Icon(Icons.warning),
              label: const Text('Emergency Alert'),
            ),
          ],
        ),
      ),
    );
  }
}
