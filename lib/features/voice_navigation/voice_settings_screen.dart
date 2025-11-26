import 'package:flutter/material.dart';
import 'package:safepath/features/voice_navigation/voice_navigation_service.dart';

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  String _lang = 'en-US';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Language', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _lang,
              items: const [
                DropdownMenuItem(value: 'en-US', child: Text('English (US)')),
                DropdownMenuItem(value: 'en-GB', child: Text('English (UK)')),
                DropdownMenuItem(value: 'es-ES', child: Text('Spanish')),
              ],
              onChanged: (v) async {
                if (v == null) return;
                setState(() => _lang = v);
                VoiceNavigationService().setLanguage(v);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await VoiceNavigationService().speak('This is a voice test in your selected language.');
              },
              child: const Text('Play test voice'),
            )
          ],
        ),
      ),
    );
  }
}
