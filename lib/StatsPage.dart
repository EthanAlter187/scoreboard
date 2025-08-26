import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/MainMenu.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:scoreboard_app/Player.dart';
import 'package:scoreboard_app/Standings.dart';
import 'package:scoreboard_app/TeamData.dart';
import 'package:scoreboard_app/main.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  StatsPageState createState() => StatsPageState();
}
/* class to display and filter player stats by team, 
sort option (points, rebounds, assists, fouls), and totals/averages */
class StatsPageState extends State<StatsPage> {
  String selectedTeam = 'All Teams';
  String sortOption = 'A-Z';
  List<Player> displayedPlayers = [];
  bool showAverages = false;

  Future<void> _searchPlayers(MyAppData data) async {
    List<Player> players;
    if (selectedTeam == 'All Teams') {
      final teams = await data.getTeams();
      players = (await Future.wait(teams.map((t) => data.getTeamPlayers(t.id))))
          .expand((p) => p)
          .toList();
    } else {
      final team = (await data.getTeams()).firstWhere((t) => t.name == selectedTeam);
      players = await data.getTeamPlayers(team.id);
    }

    switch (sortOption) {
      case 'A-Z':
        players.sort((a, b) => a.name.compareTo(b.name));
      case 'Z-A':
        players.sort((a, b) => b.name.compareTo(a.name));
      case 'Points':
        players.sort((b, a) => showAverages
            ? (a.totalPoints / (a.games == 0 ? 1 : a.games))
              .compareTo(b.totalPoints / (b.games == 0 ? 1 : b.games))
            : a.totalPoints.compareTo(b.totalPoints));
      case 'Rebounds':
        players.sort((b, a) => showAverages
            ? (a.totalRebounds / (a.games == 0 ? 1 : a.games))
              .compareTo(b.totalRebounds / (b.games == 0 ? 1 : b.games))
            : a.totalRebounds.compareTo(b.totalRebounds));
      case 'Assists':
        players.sort((b, a) => showAverages
            ? (a.totalAssists / (a.games == 0 ? 1 : a.games))
              .compareTo(b.totalAssists / (b.games == 0 ? 1 : b.games))
            : a.totalAssists.compareTo(b.totalAssists));
      case 'Fouls':
        players.sort((b, a) => showAverages
            ? (a.totalFouls / (a.games == 0 ? 1 : a.games))
              .compareTo(b.totalFouls / (b.games == 0 ? 1 : b.games))
            : a.totalFouls.compareTo(b.totalFouls));
    }

    setState(() {
      displayedPlayers = players;
    });
  }

  @override
  Widget build(BuildContext context) {
    final myAppData = context.watch<MyAppData>();
    return FutureBuilder<List<TeamData>>(
      future: myAppData.getTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final teams = snapshot.data ?? [];
        List<String> teamOptions = ['All Teams', ...teams.map((t) => t.name)];
        List<String> sortOptions = ['A-Z', 'Z-A', 'Points', 'Rebounds', 'Assists', 'Fouls'];
        List<String> statModes = ['Totals', 'Averages'];

        if (displayedPlayers.isEmpty) {
          _searchPlayers(myAppData);
        }

        return Scaffold(
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainMenu()),
                      );
                    },
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Standings()),
                      );
                    },
                    child: Text("View Standings"),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Center(
                child: Text('Stats', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 223, 211, 211),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton<String>(
                          value: selectedTeam,
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedTeam = value);
                            }
                          },
                          items: teamOptions
                              .map((team) => DropdownMenuItem<String>(
                                    value: team,
                                    child: Text(team),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 223, 211, 211),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton<String>(
                          value: sortOption,
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => sortOption = value);
                            }
                          },
                          items: sortOptions
                              .map((option) => DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        width: 120,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 223, 211, 211),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton<String>(
                          value: showAverages ? 'Averages' : 'Totals',
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                showAverages = value == 'Averages';
                              });
                            }
                          },
                          items: statModes
                              .map((mode) => DropdownMenuItem<String>(
                                    value: mode,
                                    child: Text(mode),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _searchPlayers(myAppData),
                      child: Text('Search'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: displayedPlayers.length,
                  itemBuilder: (context, index) {
                    final player = displayedPlayers[index];
                    final games = player.games == 0 ? 1 : player.games;
                    return ListTile(
                      title: Text('${player.name} (#${player.jerseyNumber})'),
                      subtitle: showAverages
                          ? Text(
                              'PPG: ${(player.totalPoints / games).toStringAsFixed(1)}, '
                              'RPG: ${(player.totalRebounds / games).toStringAsFixed(1)}, '
                              'APG: ${(player.totalAssists / games).toStringAsFixed(1)}, '
                              'FPG: ${(player.totalFouls / games).toStringAsFixed(1)}')
                          : Text(
                              'Pts: ${player.totalPoints}, Reb: ${player.totalRebounds}, '
                              'Ast: ${player.totalAssists}, PF: ${player.totalFouls}'),
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
