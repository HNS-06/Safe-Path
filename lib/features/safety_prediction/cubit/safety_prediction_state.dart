part of 'safety_prediction_cubit.dart';

sealed class SafetyPredictionState extends Equatable {
  const SafetyPredictionState();

  @override
  List<Object?> get props => [];
}

class SafetyPredictionInitial extends SafetyPredictionState {
  const SafetyPredictionInitial();
}

class SafetyPredictionLoading extends SafetyPredictionState {
  const SafetyPredictionLoading();
}

class SafetyPredictionSuccess extends SafetyPredictionState {
  const SafetyPredictionSuccess({required this.predictions});

  final List<SafetyPrediction> predictions;

  @override
  List<Object?> get props => [predictions];
}

class SafetyPredictionError extends SafetyPredictionState {
  const SafetyPredictionError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

