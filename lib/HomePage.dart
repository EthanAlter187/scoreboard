import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/CreateLeague.dart';
import 'package:scoreboard_app/JoinLeague.dart';
import 'package:scoreboard_app/MainMenu.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:scoreboard_app/OutlinedText.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppData>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 234, 221, 188),
      ),
      body: Stack( 
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedText(
                  text: "Scoreboard",
                  fontSize: 80,
                  fillColor: Colors.black,   
                  outlineColor: Colors.white,  
                  strokeWidth: 1.5,
                ),
                SizedBox(height: 30.0),
                // only show continue button if user has a current league
                if (appState.currentLeagueId != null) 
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () async{
                        await appState.initCurrentLeague();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => MainMenu()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 8,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      ),
                      child: Text("Continue League", style: TextStyle(fontSize: 24)),
                    ),
                  ),
                SizedBox(height: 12.0),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateLeague()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 8,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    ),
                    child: Text("Create League", style: TextStyle(fontSize: 25)),
                  ),
                ),
                SizedBox(height: 12.0),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JoinLeague()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 8,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    ),
                    child: Text("Join League", style: TextStyle(fontSize: 25)),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.logout, size: 35),
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                },
              ),
            ),
          ),
        ]
      )
    );
  }
}
