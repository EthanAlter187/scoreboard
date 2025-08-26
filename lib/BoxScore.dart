import 'package:flutter/material.dart';
import 'package:scoreboard_app/Player.dart';
import 'package:scoreboard_app/PlayerStats.dart';

class BoxScore extends StatelessWidget {
  final List<Player> players;
  final Map<String, PlayerStats> stats;

  const BoxScore({required this.players, required this.stats, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
          child: Row(
            children: const [
              Expanded(flex: 3, child: Text('Player', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
              Expanded(child: Text('PTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
              Expanded(child: Text('REB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
              Expanded(child: Text('AST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
              Expanded(child: Text('PF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
            ],
          ),
        ),
        Divider(thickness: 1),
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              final stat = stats[player.id] ?? PlayerStats();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('${player.name} (#${player.jerseyNumber})', style: TextStyle(fontSize: 22))),
                    Expanded(child: Text(stat.points.toString(), style: TextStyle(fontSize: 22))),
                    Expanded(child: Text(stat.rebounds.toString(), style: TextStyle(fontSize: 22))),
                    Expanded(child: Text(stat.assists.toString(), style: TextStyle(fontSize: 22))),
                    Expanded(child: Text(stat.fouls.toString(), style: TextStyle(fontSize: 22))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
