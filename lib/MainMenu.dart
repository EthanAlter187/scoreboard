import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/League.dart';
import 'package:scoreboard_app/LeagueView.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:scoreboard_app/OutlinedText.dart';
import 'package:scoreboard_app/PlaySchedule.dart';
import 'package:scoreboard_app/ScheduleMenu.dart';
import 'package:scoreboard_app/SettingsPage.dart';
import 'package:scoreboard_app/StatsPage.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MyAppData>();
    return FutureBuilder<League>(
      future: data.getCurrentLeague(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final leagueName = snapshot.data?.name ?? 'Loading...';
        return Scaffold(
          body: Stack( 
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedText(
                        text: leagueName,
                        fontSize: 80,
                        fillColor: Colors.black,
                        outlineColor: Colors.white, 
                        strokeWidth: 1.5,
                      ),
                      SizedBox(height: 60),
                      ElevatedButton(
                        onPressed: () {
                          if (data.slates.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PlaySchedule()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('You must create a schedule first')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 8,
                          minimumSize: Size(250, 60),
                          textStyle: TextStyle(fontSize: 20),
                        ),
                        child: Text(data.isAdmin ? "Start Game" : "View Schedule"),
                      ),
                      if (data.isAdmin)
                        SizedBox(height: 15),
                      if (data.isAdmin)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ScheduleMenu()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 8,
                            minimumSize: Size(250, 60),
                            textStyle: TextStyle(fontSize: 20),
                          ),
                          child: Text("Create Schedule"),
                        ),
                      if (data.isAdmin)
                        SizedBox(height: 15),
                      if (data.isAdmin)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LeagueView()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 8,
                            minimumSize: Size(250, 60),
                            textStyle: TextStyle(fontSize: 20),
                          ),
                          child: Text("Edit Teams & Players"),
                        ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StatsPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 8,
                          minimumSize: Size(250, 60),
                          textStyle: TextStyle(fontSize: 20),
                        ),
                        child: Text("Stats/Standings"),
                      ),
                    ],
                  ),
                ),
              ),
              if (data.isAdmin)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.settings, size: 46),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SettingsPage()),
                        );
                      },
                    ),
                  ),
                ),
            ]
          ),
        );
      },
    );
  }
}
