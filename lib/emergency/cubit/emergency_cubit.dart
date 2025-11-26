import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:safepath/emergency/models/emergency_alert.dart';
import 'package:safepath/emergency/models/emergency_contact.dart';
import 'package:safepath/emergency/services/emergency_service.dart';

part 'emergency_state.dart';

class EmergencyCubit extends Cubit<EmergencyState> {
  EmergencyCubit({EmergencyService? service})
      : _service = service ?? EmergencyService(),
        super(const EmergencyState.initial());

  final EmergencyService _service;
  StreamSubscription<List<EmergencyAlert>>? _subscription;

  Future<void> start() async {
    emit(state.copyWith(status: EmergencyStatus.loading));
    try {
      final contacts = await _service.getEmergencyContacts();
      _subscription?.cancel();
      _subscription = _service.watchAlerts().listen((alerts) {
        emit(
          state.copyWith(
            status: EmergencyStatus.success,
            alerts: alerts,
            contacts: contacts,
          ),
        );
      });
    } catch (error) {
      emit(
        state.copyWith(
          status: EmergencyStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> sendHelpRequest({
    required String message,
    bool shareLocation = true,
  }) async {
    emit(state.copyWith(isHelpRequestInProgress: true));
    try {
      final ticketId = await _service.triggerHelpRequest(
        message: message,
        shareLocation: shareLocation,
      );
      emit(
        state.copyWith(
          isHelpRequestInProgress: false,
          lastTicketId: ticketId,
          lastHelpRequestTime: DateTime.now(),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isHelpRequestInProgress: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

