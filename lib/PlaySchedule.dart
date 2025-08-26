import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/MainMenu.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:scoreboard_app/Scorekeeping.dart';
import 'package:scoreboard_app/TeamData.dart';
import 'package:scoreboard_app/main.dart';

class PlaySchedule extends StatefulWidget {
  const PlaySchedule({super.key});

  @override
  PlayScheduleState createState() => PlayScheduleState();
}

// Class to display the schedule with games for the current week
// Includes play/continue/view button to navigate to scorekeeping for each game
class PlayScheduleState extends State<PlaySchedule> {
  int currentSlateIndex = 0;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MyAppData>();
    final slate = data.slates[currentSlateIndex];
    final slateGames = data.games.where((g) => g.slateId == slate.id).toList();
    return FutureBuilder<List<TeamData>>(
      future: data.getTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final teams = snapshot.data ?? [];
        return Scaffold(
          appBar: AppBar(
            title: Text(slate.name),
            centerTitle: true,
            leadingWidth: 280,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainMenu()),
                    );
                  },
                  child: Text(
                    "Back to Menu",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (currentSlateIndex > 0) {
                      setState(() {
                        currentSlateIndex--;
                      });
                    }
                  },
                  child: Text(
                    "← Previous Week",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await data.addSlate();
                  setState(() {
                    currentSlateIndex++;
                  });
                },
                child: Text(
                  "Next Week →",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              SizedBox(width: 12),
            ],
          ),
          body: slateGames.isEmpty
              ? Center(child: Text("No games scheduled for this week."))
              : ListView.builder(
                  itemCount: slateGames.length,
                  itemBuilder: (context, index) {
                    final game = slateGames[index];
                    final teamA = teams.firstWhere((t) => t.id == game.teamAId,
                      orElse: () => TeamData(id: '', leagueId: '', name: 'Unknown'));
                    final teamB = teams.firstWhere((t) => t.id == game.teamBId,
                      orElse: () => TeamData(id: '', leagueId: '', name: 'Unknown'));
                    String scoreA = game.hasStarted ? "${game.scoreA}" : "-";
                    String scoreB = game.hasStarted ? "${game.scoreB}" : "-";
                    // button text depends on game status and user permissions
                    String label = !game.hasStarted && data.isAdmin
                        ? "Start"
                        : !game.isCompleted && data.isAdmin
                            ? "Continue"
                            : "View";
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('MMM d, yyyy').format(game.gameDate),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        "${teamA.name} ",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(width: 275),
                                      Text(
                                        scoreA,
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "vs.",
                                  style: TextStyle(fontSize: 18),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        scoreB,
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 275),
                                      Text(
                                        "${teamB.name} ",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 7),
                            if (game.hasStarted)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      !game.isCompleted ? 'Q${game.quarter}' : "Final",
                                      style: TextStyle(fontSize: 16)),
                                  if (!game.isCompleted) SizedBox(width: 12),
                                  if (!game.isCompleted)
                                    Text(game.timeLeft.toString().substring(2, 7),
                                        style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            SizedBox(height: 4),
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Scorekeeping(
                                        game: game,
                                        teamA: teamA,
                                        teamB: teamB,
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                },
                                child: Text(label),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
