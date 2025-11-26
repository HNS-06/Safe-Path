import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safepath/emergency/cubit/emergency_cubit.dart';
import 'package:safepath/emergency/models/emergency_alert.dart';
import 'package:safepath/emergency/models/emergency_contact.dart';
import 'package:safepath/theme/colors.dart';

class EmergencyCenterScreen extends StatelessWidget {
  const EmergencyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmergencyCubit()..start(),
      child: const _EmergencyView(),
    );
  }
}

class _EmergencyView extends StatelessWidget {
  const _EmergencyView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Emergency Center'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocConsumer<EmergencyCubit, EmergencyState>(
        listener: (context, state) {
          if (state.lastTicketId != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Help request submitted • Ticket ${state.lastTicketId}',
                ),
              ),
            );
          }
          if (state.errorMessage != null &&
              state.status == EmergencyStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == EmergencyStatus.loading ||
              state.status == EmergencyStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<EmergencyCubit>().start(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: [
                _HeroHelpCard(
                  isLoading: state.isHelpRequestInProgress,
                  onPressed: () => _showHelpModal(context),
                ),
                const SizedBox(height: 20),
                _QuickActions(
                  onFakeCall: () => _showSnack(
                    context,
                    'Launching safe-mode fake call…',
                  ),
                  onShareLocation: () => _showSnack(
                    context,
                    'Sharing live location with guardians…',
                  ),
                  onEmergencyContacts: () => _showContactsSheet(
                    context,
                    state.contacts,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Live Alerts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...state.alerts.map((alert) => _AlertTile(alert: alert)),
                if (state.alerts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'You are in a safe zone right now.\nStay alert and keep reporting!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showHelpModal(BuildContext context) async {
    final controller = TextEditingController(text: 'Need assistance nearby.');
    final cubit = context.read<EmergencyCubit>();
    final shareLocation = ValueNotifier<bool>(true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Help Needed',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe your situation…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: shareLocation,
                builder: (context, value, child) => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: value,
                  onChanged: (selected) => shareLocation.value = selected,
                  title: const Text('Share live location with guardians'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    cubit.sendHelpRequest(
                      message: controller.text,
                      shareLocation: shareLocation.value,
                    );
                  },
                  icon: const Icon(Icons.sos),
                  label: const Text(
                    'Send Emergency Beacon',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContactsSheet(
    BuildContext context,
    List<EmergencyContact> contacts,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Emergency Contacts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...contacts.map(
              (contact) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: Icon(contact.icon, color: AppColors.primary),
                ),
                title: Text(contact.name),
                subtitle: Text(contact.role),
                trailing: IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: () => _showSnack(
                    context,
                    'Dialing ${contact.phone}…',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHelpCard extends StatelessWidget {
  const _HeroHelpCard({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF476F), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF476F).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Help',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notify guardians + share location instantly.\nAvailable 24/7.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    width: isLoading ? 140 : 160,
                    height: isLoading ? 140 : 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.danger,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(32),
                    ),
                    onPressed: isLoading ? null : onPressed,
                    child: isLoading
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(),
                          )
                        : const Text(
                            'SOS',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onEmergencyContacts,
    required this.onShareLocation,
    required this.onFakeCall,
  });

  final VoidCallback onEmergencyContacts;
  final VoidCallback onShareLocation;
  final VoidCallback onFakeCall;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        icon: Icons.share_location,
        label: 'Share Live Location',
        onTap: onShareLocation,
        color: AppColors.primary
      ),
      (
        icon: Icons.people_alt,
        label: 'Guardian Desk',
        onTap: onEmergencyContacts,
        color: AppColors.safe
      ),
      (
        icon: Icons.phone_callback,
        label: 'Fake Call',
        onTap: onFakeCall,
        color: AppColors.warning
      ),
    ];

    return Row(
      children: actions
          .map(
            (action) => Expanded(
              child: GestureDetector(
                onTap: action.onTap,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Icon(action.icon, color: action.color),
                      const SizedBox(height: 8),
                      Text(
                        action.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: action.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final EmergencyAlert alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: alert.severityColor.withOpacity(0.15),
            child: Icon(alert.typeIcon, color: alert.severityColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${alert.locationName} • ${(alert.distanceInMeters / 1000).toStringAsFixed(1)} km',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: alert.severityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Lv ${alert.severity}',
                  style: TextStyle(
                    color: alert.severityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Icon(
                alert.isActive ? Icons.wifi_tethering : Icons.check_circle,
                color: alert.isActive
                    ? AppColors.warning
                    : AppColors.safe,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

