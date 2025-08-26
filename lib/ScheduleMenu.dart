import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/MainMenu.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:scoreboard_app/TeamData.dart';

class ScheduleMenu extends StatefulWidget {
  const ScheduleMenu({super.key});

  @override
  State<ScheduleMenu> createState() => _ScheduleMenuState();
}

// Class to manage the schedule menu where users can view and edit game schedules
// Allows navigation between weeks, adding games, and editing game details
class _ScheduleMenuState extends State<ScheduleMenu> {
  int currentSlateIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<MyAppData>().initSchedule();
  }

  Future<void> _pickDate(BuildContext context, int slateIndex, int gameIndex) async {
    final data = context.read<MyAppData>();
    final slateId = data.slates[slateIndex].id;
    final slateGames = data.games.where((g) => g.slateId == slateId).toList();
    if (gameIndex >= slateGames.length) return;
    final initialDate = slateGames[gameIndex].gameDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      await data.updateGame(slateGames[gameIndex], gameDate: picked);
    }
  }


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
              ],
            ),
            actions: [
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
              ? Center(
                  child: ElevatedButton(
                    child: Text("Add Game +", style: TextStyle(fontSize: 24)),
                    onPressed: () async {
                      await data.addGameToSlate(currentSlateIndex);
                      setState(() {});
                    },
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: slateGames.length + 1,
                        itemBuilder: (context, index) {
                          if (index == slateGames.length) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                child: Text("Add Game +", style: TextStyle(fontSize: 24)),
                                onPressed: () async {
                                  await data.addGameToSlate(currentSlateIndex);
                                  setState(() {});
                                },
                              ),
                            );
                          }
                          final game = slateGames[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButton<String>(
                                          value: game.teamAId,
                                          items: teams
                                              .map((t) => DropdownMenuItem(
                                                    value: t.id,
                                                    child: Text(t.name),
                                                  ))
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              data.updateGame(game, teamAId: val);
                                            }
                                          },
                                          isExpanded: true,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text("vs.", style: TextStyle(fontSize: 18)),
                                      ),
                                      Expanded(
                                        child: DropdownButton<String>(
                                          value: game.teamBId,
                                          items: teams
                                              .map((t) => DropdownMenuItem(
                                                    value: t.id,
                                                    child: Text(t.name),
                                                  ))
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              data.updateGame(game, teamBId: val);
                                            }
                                          },
                                          isExpanded: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton.icon(
                                          icon: Icon(Icons.calendar_today),
                                          label: Text(DateFormat.yMMMd().format(game.gameDate)),
                                          onPressed: () => _pickDate(context, currentSlateIndex, index),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          await data.removeGame(currentSlateIndex, index);
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
