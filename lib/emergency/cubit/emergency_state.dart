part of 'emergency_cubit.dart';

enum EmergencyStatus { initial, loading, success, failure }

class EmergencyState extends Equatable {
  const EmergencyState({
    required this.status,
    required this.alerts,
    required this.contacts,
    required this.isHelpRequestInProgress,
    required this.lastHelpRequestTime,
    required this.lastTicketId,
    required this.errorMessage,
  });

  const EmergencyState.initial()
      : this(
          status: EmergencyStatus.initial,
          alerts: const [],
          contacts: const [],
          isHelpRequestInProgress: false,
          lastHelpRequestTime: null,
          lastTicketId: null,
          errorMessage: null,
        );

  final EmergencyStatus status;
  final List<EmergencyAlert> alerts;
  final List<EmergencyContact> contacts;
  final bool isHelpRequestInProgress;
  final DateTime? lastHelpRequestTime;
  final String? lastTicketId;
  final String? errorMessage;

  EmergencyState copyWith({
    EmergencyStatus? status,
    List<EmergencyAlert>? alerts,
    List<EmergencyContact>? contacts,
    bool? isHelpRequestInProgress,
    DateTime? lastHelpRequestTime,
    String? lastTicketId,
    String? errorMessage,
  }) {
    return EmergencyState(
      status: status ?? this.status,
      alerts: alerts ?? this.alerts,
      contacts: contacts ?? this.contacts,
      isHelpRequestInProgress:
          isHelpRequestInProgress ?? this.isHelpRequestInProgress,
      lastHelpRequestTime: lastHelpRequestTime ?? this.lastHelpRequestTime,
      lastTicketId: lastTicketId ?? this.lastTicketId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        alerts,
        contacts,
        isHelpRequestInProgress,
        lastHelpRequestTime,
        lastTicketId,
        errorMessage,
      ];
}

