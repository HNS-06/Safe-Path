import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:safepath/ai/models/safety_prediction.dart';
import 'package:safepath/ai/safety_prediction_service.dart';
import 'package:safepath/models/location_model.dart';
import 'package:safepath/services/location_service.dart';

part 'safety_prediction_state.dart';

class SafetyPredictionCubit extends Cubit<SafetyPredictionState> {
  SafetyPredictionCubit({
    SafetyPredictionService? predictionService,
  })  : _predictionService = predictionService ?? SafetyPredictionService(),
        super(const SafetyPredictionInitial());

  final SafetyPredictionService _predictionService;

  Future<void> loadPredictions({bool demoMode = true}) async {
    emit(const SafetyPredictionLoading());
    try {
      final location = await _getCurrentLocationOrFallback();
      final predictions = await _predictionService.getPredictions(
        location: location,
        time: DateTime.now(),
        demoMode: demoMode,
      );
      emit(SafetyPredictionSuccess(predictions: predictions));
    } catch (error) {
      emit(SafetyPredictionError(message: error.toString()));
    }
  }

  Future<LocationModel> _getCurrentLocationOrFallback() async {
    try {
      final geoPosition = await LocationService.getCurrentLocation();
      return LocationModel(
        latitude: geoPosition.latitude,
        longitude: geoPosition.longitude,
        timestamp: DateTime.now(),
      );
    } catch (_) {
      return LocationModel(
        latitude: 28.6139,
        longitude: 77.2090,
        timestamp: DateTime.now(),
        address: 'Central Demo District',
      );
    }
  }
}

