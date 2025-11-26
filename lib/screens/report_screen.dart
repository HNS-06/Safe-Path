import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safepath/models/safety_report.dart';
import 'package:safepath/services/voice_service.dart';
import 'package:safepath/services/location_service.dart';
import 'package:safepath/services/database_service.dart';
import 'package:safepath/widgets/animated_button.dart';
import 'package:safepath/theme/colors.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  SafetyType _selectedSafetyType = SafetyType.safe;
  final TextEditingController _descriptionController = TextEditingController();
  double _safetyRating = 3.0;
  bool _isListening = false;
  String _voiceText = '';

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
    // Initialize voice service asynchronously
    VoiceService().initialize().catchError((error) {
      // Voice service initialization failed, but app can continue
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _startVoiceInput() async {
    if (!mounted) return;
    
    setState(() {
      _isListening = true;
      _voiceText = '';
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    final report = await VoiceService().listenForSafetyReport(
      onResult: (text) {
        if (!mounted) return;
        setState(() {
          _voiceText = text;
        });
        
        // Parse and update form
        final type = VoiceService.parseSafetyCommand(text);
        if (type != null && mounted) {
          setState(() {
            _selectedSafetyType = type;
            _descriptionController.text = text;
            _safetyRating = type == SafetyType.safe ? 4.5 : 
                          (type == SafetyType.moderate ? 3.0 : 2.0);
          });
        }
      },
      onError: (error) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Voice error: $error')),
          );
        }
      },
    );

    if (!mounted) return;
    setState(() => _isListening = false);

    if (report != null) {
      // Get current location and submit
      try {
        final location = await LocationService.getCurrentLocation();
        final finalReport = SafetyReport(
          id: report.id,
          location: LatLng(location.latitude, location.longitude),
          type: report.type,
          description: report.description,
          rating: report.rating,
          timestamp: report.timestamp,
        );
        
        await DatabaseService().addSafetyReport(finalReport);
        _confettiController.play();
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => SuccessDialog(
              confettiController: _confettiController,
              onClose: () => navigator.pop(),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Location error: $e')),
          );
        }
      }
    }
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      _confettiController.play();
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => SuccessDialog(
          confettiController: _confettiController,
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildVoiceAssistantButton(),
                  const SizedBox(height: 20),
                  if (_voiceText.isNotEmpty) _buildVoiceResult(),
                  const SizedBox(height: 10),
                  _buildSafetyTypeSelector(),
                  const SizedBox(height: 30),
                  _buildSafetyRating(),
                  const SizedBox(height: 30),
                  _buildDescriptionField(),
                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
        
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [
              AppColors.primary,
              AppColors.secondary,
              AppColors.accent,
              AppColors.warning,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Safety Issue',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Help others by sharing safety information about your route',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Safety Level',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: SafetyType.values.map((type) {
            final isSelected = _selectedSafetyType == type;
            return ChoiceChip(
              label: Text(
                type.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSafetyType = type;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: _getSafetyColor(type),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSafetyRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Safety Rating: ${_safetyRating.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _safetyRating,
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (value) {
            setState(() {
              _safetyRating = value;
            });
          },
          activeColor: _getSafetyColor(_selectedSafetyType),
          inactiveColor: Colors.grey[300],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['1', '2', '3', '4', '5'].map((text) {
            return Text(
              text,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Additional Details',
        hintText: 'Describe the safety condition, time of day, suggestions...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please provide some details';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: AnimatedButton(
        onPressed: _submitReport,
        child: const Text(
          'Submit Report',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceAssistantButton() {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _isListening
                  ? LinearGradient(
                      colors: [AppColors.danger, AppColors.warning],
                    )
                  : AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: (_isListening ? AppColors.danger : AppColors.primary)
                      .withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isListening
                    ? () async {
                        await VoiceService().stopListening();
                        setState(() => _isListening = false);
                      }
                    : _startVoiceInput,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isListening ? 'Listening...' : 'Tap to use Voice Assistant',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_isListening)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Say: "It is safe", "It is not safe", "Traffic more than usual"',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceResult() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Voice: $_voiceText',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSafetyColor(SafetyType type) {
    switch (type) {
      case SafetyType.safe: return AppColors.safe;
      case SafetyType.moderate: return AppColors.moderate;
      case SafetyType.unsafe: return AppColors.unsafe;
      default: return AppColors.unknown;
    }
  }
}

class SuccessDialog extends StatelessWidget {
  final ConfettiController confettiController;
  final VoidCallback onClose;

  const SuccessDialog({
    super.key,
    required this.confettiController,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.accent,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Report Submitted!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Thank you for helping make our community safer',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 30),
            AnimatedButton(
              onPressed: onClose,
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}