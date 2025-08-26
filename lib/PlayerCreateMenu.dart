import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:scoreboard_app/MyTextField.dart';
import 'package:scoreboard_app/Player.dart';
import 'package:scoreboard_app/TeamData.dart';

class PlayerCreateMenu extends StatefulWidget {
  final String teamId;
  final VoidCallback onBack;

  const PlayerCreateMenu({super.key, required this.teamId, required this.onBack});

  @override
  State<PlayerCreateMenu> createState() => _PlayerCreateMenuState();
}

// Class to manage player creation and editing for a specific team
// Customizes player name, jersey number, and age
class _PlayerCreateMenuState extends State<PlayerCreateMenu> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController jerseyController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  bool isEdit = false;
  String? editPlayerId;

  @override
  Widget build(BuildContext context) {
    final myAppData = context.watch<MyAppData>();
    return FutureBuilder<List<Player>>(
      future: myAppData.getTeamPlayers(widget.teamId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final players = snapshot.data ?? [];
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: widget.onBack,
            tooltip: 'Back',
            child: Icon(Icons.arrow_back),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: FutureBuilder<TeamData>(
                    future: myAppData.getTeam(widget.teamId),
                    builder: (context, teamSnapshot) {
                      if (teamSnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      return Text(
                        teamSnapshot.data?.name ?? '',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12),
                MyTextField(
                  controller: nameController,
                  isNumeric: false,
                  label: "Name",
                ),
                MyTextField(
                  controller: jerseyController,
                  isNumeric: true,
                  label: "Jersey #",
                ),
                MyTextField(
                  controller: ageController,
                  isNumeric: true,
                  label: "Age",
                ),
                ElevatedButton(
                  onPressed: () async {
                    final playerName = nameController.text;
                    final jersey = int.tryParse(jerseyController.text) ?? 0;
                    final age = int.tryParse(ageController.text) ?? 0;

                    if (playerName.isNotEmpty) {
                      try {
                        if (!isEdit) {
                          await myAppData.addPlayer(widget.teamId, playerName, age, jersey);
                        } else if (editPlayerId != null) {
                          await myAppData.editPlayer(editPlayerId!, playerName, age, jersey);
                          isEdit = false;
                        }
                        setState(() {
                          nameController.clear();
                          jerseyController.clear();
                          ageController.clear();
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: Text(isEdit ? "Update Player" : "Add Player"),
                ),
                SizedBox(height: 24),
                Text(
                  "Current Players",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Jersey #", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Age", style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 80),
                  ],
                ),
                Divider(),
                ...players.asMap().entries.map((entry) {
                  Player p = entry.value;
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(p.name)),
                          Expanded(child: Text(p.jerseyNumber.toString())),
                          Expanded(child: Text(p.age.toString())),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              nameController.text = p.name;
                              jerseyController.text = p.jerseyNumber.toString();
                              ageController.text = p.age.toString();
                              setState(() {
                                isEdit = true;
                                editPlayerId = p.id;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              try {
                                await myAppData.removePlayer(widget.teamId, p.id);
                                setState(() {});
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    jerseyController.dispose();
    ageController.dispose();
    super.dispose();
  }
}
