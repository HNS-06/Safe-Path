import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:safepath/models/buddy.dart';
import 'package:safepath/services/buddy_service.dart';
import 'package:safepath/theme/colors.dart';

class GuardianListScreen extends StatefulWidget {
  const GuardianListScreen({super.key});

  @override
  State<GuardianListScreen> createState() => _GuardianListScreenState();
}

class _GuardianListScreenState extends State<GuardianListScreen> {
  final _service = BuddyService();

  @override
  void initState() {
    super.initState();
    _service.getBuddies();
  }

  Future<void> _addMockBuddy() async {
    final id = const Uuid().v4();
    final buddy = Buddy(
      id: id,
      name: 'Guardian ${id.substring(0, 8)}',
      phone: '+1 555 0${id.hashCode % 9999}',
    );
    await _service.addBuddy(buddy);
  }

  Future<void> _removeBuddy(String id) async {
    await _service.removeBuddy(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Guardians & Buddies'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ValueListenableBuilder<List<Buddy>>(
        valueListenable: _service.buddiesNotifier,
        builder: (context, buddies, _) {
          if (buddies.isEmpty) {
            return Center(
              child: Text(
                'No guardians added yet.\nAdd someone you trust!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: buddies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final b = buddies[i];
              return Dismissible(
                key: ValueKey(b.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _removeBuddy(b.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  tileColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: CircleAvatar(child: Text(b.name.isNotEmpty ? b.name[0] : '?')),
                  title: Text(b.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.phone ?? ''),
                      if (b.lastSeen != null)
                        Text('Last seen: ${b.lastSeen!.toLocal().toString().split('.').first}',
                            style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: b.isVerified ? const Icon(Icons.verified, color: Colors.green) : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMockBuddy,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
