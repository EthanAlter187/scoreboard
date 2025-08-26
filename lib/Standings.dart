import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/MainMenu.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:scoreboard_app/StatsPage.dart';
import 'package:scoreboard_app/TeamData.dart';

class Standings extends StatelessWidget {
  const Standings({super.key});

  @override
  Widget build(BuildContext context) {
    final myAppData = context.watch<MyAppData>();
    return FutureBuilder<List<TeamData>>(
      future: myAppData.getTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final teams = snapshot.data ?? [];
        List<TeamData> sortedTeams = [...teams];
        sortedTeams.sort((b, a) {
          double winPctA = a.gamesPlayed == 0 ? 0 : a.wins / a.gamesPlayed;
          double winPctB = b.gamesPlayed == 0 ? 0 : b.wins / b.gamesPlayed;
          return winPctA == winPctB
              ? a.pointDiff.compareTo(b.pointDiff)
              : winPctA.compareTo(winPctB);
        });

        return Scaffold(
          body: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainMenu()),
                      );
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const StatsPage()),
                      );
                    },
                    child: const Text("View Stats"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Standings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
                    Expanded(child: Text('W-L', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
                    Expanded(child: Text('PCT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
                    Expanded(child: Text('PD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedTeams.length,
                  itemBuilder: (context, index) {
                    final team = sortedTeams[index];
                    final winPct = team.gamesPlayed == 0 ? 0.0 : team.wins / team.gamesPlayed;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                      child: Row(
                        children: [
                          Container(width: 12, height: 12,
                            decoration: BoxDecoration(
                              color: team.colorValue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(flex: 3, child: Text(team.name, style: const TextStyle(fontSize: 22))),
                          Expanded(child: Text('${team.wins}-${team.losses}', style: const TextStyle(fontSize: 22))),
                          Expanded(child: Text(winPct.toStringAsFixed(3), style: const TextStyle(fontSize: 22))),
                          Expanded(child: Text(team.pointDiff.toString(), style: const TextStyle(fontSize: 22))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
