import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/LeagueView.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:scoreboard_app/MyTextField.dart';

class CreateCard extends StatefulWidget {
  const CreateCard({super.key});

  @override
  State<CreateCard> createState() => _CreateCardState();
}

class _CreateCardState extends State<CreateCard> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 20,
      margin: EdgeInsets.all(37),
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("League Setup", style: TextStyle(fontSize: 20)),
            MyTextField(controller: nameController, isNumeric: false, label: 'League Name'),
            MyTextField(controller: numberController, isNumeric: true, label: '# of Teams'),
            ElevatedButton(
              onPressed: () async {
                final MyAppData leagueData = context.read<MyAppData>();
                final String name = nameController.text;
                final int totalTeams = int.tryParse(numberController.text) ?? 0;
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('League Name is empty!')),
                  );
                  return;
                }
                if (totalTeams <= 0 || totalTeams > 40) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('The number of teams must be between 1 and 40!')),
                  );
                  numberController.clear();
                  return;
                }
                try {
                  await leagueData.createLeague(name, totalTeams);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LeagueView()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating league: $e')),
                  );
                }
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
