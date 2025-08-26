import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/MainMenu.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:scoreboard_app/MyTextField.dart';


class JoinLeague extends StatefulWidget {
  @override
  JoinLeagueState createState() => JoinLeagueState();
}
// Class to handle joining a league by entering an invite code
class JoinLeagueState extends State<JoinLeague> {
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 234, 221, 188),
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(20),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextField(
                  controller: codeController,
                  isNumeric: false,
                  label: 'League Code',
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final code = codeController.text;
                    if (code.isNotEmpty) {
                      try {
                        await context.read<MyAppData>().joinLeague(code);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainMenu()),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error joining league: $e')),
                        );
                      }
                    }
                  },
                  child: Text('Join'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }
}
