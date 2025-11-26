import 'package:flutter/material.dart';
import 'package:safepath/theme/colors.dart';
import 'package:safepath/services/gamification_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = GamificationService();
    final leaderboard = service.getLeaderboard();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white 
            : AppColors.textPrimary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = leaderboard[index];
          return ListTile(
            tileColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : null,
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(item['name'] as String,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
            trailing: Text('${item['points']}',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => Divider(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[300],
        ),
        itemCount: leaderboard.length,
      ),
    );
  }
}
