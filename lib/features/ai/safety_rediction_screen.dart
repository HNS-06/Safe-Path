import 'package:flutter/material.dart';
import 'package:safepath/features/ai/ai_safety_predictor.dart';
import 'package:safepath/models/ai_prediction_model.dart';
import 'package:safepath/widgets/safety_prediction_card.dart';
import 'package:confetti/confetti.dart';

class SafetyPredictionScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const SafetyPredictionScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<SafetyPredictionScreen> createState() => _SafetyPredictionScreenState();
}

class _SafetyPredictionScreenState extends State<SafetyPredictionScreen> {
  final AISafetyPredictor _predictor = AISafetyPredictor();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  SafetyPrediction? _currentPrediction;
  bool _isLoading = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // Set initial values if provided
    if (widget.initialLat != null) {
      _latController.text = widget.initialLat.toString();
    }
    if (widget.initialLng != null) {
      _lngController.text = widget.initialLng.toString();
    }
    
    _timeController.text = _formatTime(DateTime.now());
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _predictSafety() async {
    if (_latController.text.isEmpty || _lngController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter location coordinates')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _currentPrediction = null;
    });

    try {
      final lat = double.parse(_latController.text);
      final lng = double.parse(_lngController.text);
      final time = DateTime.now(); // In real app, parse from _timeController

      final prediction = await _predictor.predictSafety(lat, lng, time);
      
      setState(() {
        _currentPrediction = prediction;
      });

      // Celebrate if prediction is very safe
      if (prediction.score >= 4.5) {
        _confettiController.play();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Safety Predictor'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Section
                _buildInputSection(),
                const SizedBox(height: 30),
                
                // Prediction Result
                if (_isLoading) _buildLoadingIndicator(),
                if (_currentPrediction != null) 
                  SafetyPredictionCard(prediction: _currentPrediction!),
                
                // Quick Actions
                const SizedBox(height: 30),
                _buildQuickActions(),
              ],
            ),
          ),
          
          // Confetti for celebrations
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Predict Area Safety',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Time (HH:MM)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _predictSafety,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Predict Safety Score',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'AI is analyzing safety factors...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Considering time, lighting, historical data, and more',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Predictions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionButton('Current Location', Icons.my_location, () {
              // In real app, get current location
              _latController.text = '28.6139';
              _lngController.text = '77.2090';
            }),
            _buildQuickActionButton('Home Area', Icons.home, () {
              _latController.text = '28.6129';
              _lngController.text = '77.2295';
            }),
            _buildQuickActionButton('Work Area', Icons.work, () {
              _latController.text = '28.6149';
              _lngController.text = '77.2190';
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String text, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      onPressed: onTap,
      backgroundColor: Colors.blue[50],
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selected = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      _timeController.text = _formatTime(selected);
    }
  }
}