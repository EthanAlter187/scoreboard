import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:scoreboard_app/MyTextField.dart';

class TeamCreate extends StatefulWidget {
  const TeamCreate({
    super.key,
    required this.index,
    required this.onAddPlayers,
  });

  final int index;
  final VoidCallback onAddPlayers;

  @override
  State<TeamCreate> createState() => _TeamCreateState();
}

class _TeamCreateState extends State<TeamCreate> {
  late TextEditingController nameController;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    final team = context.read<MyAppData>().teams[widget.index];
    nameController = TextEditingController(text: team.name);
    selectedColor = Color(int.parse(team.color.replaceFirst('#', '0xFF')));
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myAppData = context.read<MyAppData>();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Team Details", style: TextStyle(fontSize: 30)),
                SizedBox(height: 40),
                MyTextField(controller: nameController, isNumeric: false, label: "Team Name"),
                SizedBox(height: 40),
                Text("Team Color:", style: TextStyle(fontSize: 20)),
                Row(
                  children: [
                    ColorPicker(
                      pickerColor: selectedColor,
                      onColorChanged: (Color color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      enableAlpha: false,
                      displayThumbColor: true,
                      pickerAreaHeightPercent: 0.8,
                    ),
                    SizedBox(width: 170),
                    ElevatedButton(
                      onPressed: () async {
                        final String teamName = nameController.text;
                        await myAppData.createTeam(widget.index, teamName, selectedColor);
                      },
                      style: ElevatedButton.styleFrom(minimumSize: Size(175, 75)),
                      child: Text("Submit", style: TextStyle(fontSize: 30)),
                    ),
                    SizedBox(width: 35),
                    ElevatedButton(
                      onPressed: widget.onAddPlayers,
                      style: ElevatedButton.styleFrom(minimumSize: Size(175, 75)),
                      child: Text("Add Players", style: TextStyle(fontSize: 30)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
