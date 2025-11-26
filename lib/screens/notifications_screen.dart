import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safepath/services/notifications_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsService _service = NotificationsService();

  @override
  void initState() {
    super.initState();
    // seed demo notifications so the screen isn't blank
    _service.seedDemoIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            tooltip: 'Mark all read',
            onPressed: () {
              _service.markAllRead();
              setState(() {});
            },
          )
        ],
      ),
      body: ValueListenableBuilder<List<NotificationItem>>(
        valueListenable: _service.notifications,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_off, size: 64, 
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[600]
                        : Colors.grey),
                    const SizedBox(height: 12),
                    Text('No notifications yet.',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white
                          : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('You will see important alerts and updates here.',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70
                          : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[300],
            ),
            itemBuilder: (context, index) {
              final item = list[index];
              final ts = DateFormat.yMMMd().add_jm().format(item.timestamp);
              return ListTile(
                tileColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : null,
                leading: CircleAvatar(
                  backgroundColor: item.read 
                      ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey.shade300)
                      : Theme.of(context).primaryColor,
                  child: Icon(
                    item.read ? Icons.notifications : Icons.notifications_active,
                    color: item.read 
                        ? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54)
                        : Colors.white,
                  ),
                ),
                title: Text(item.title,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text('${item.body}\n$ts', maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey,
                  ),
                ),
                isThreeLine: true,
                trailing: item.read
                    ? null
                    : TextButton(
                        child: const Text('Mark'),
                        onPressed: () {
                          _service.markRead(item.id);
                          setState(() {});
                        },
                      ),
                onTap: () {
                  if (!item.read) _service.markRead(item.id);
                  setState(() {});
                },
              );
            },
          );
        },
      ),
    );
  }
}
