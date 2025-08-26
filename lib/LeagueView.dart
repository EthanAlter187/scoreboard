import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/MainMenu.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:scoreboard_app/PlayerCreateMenu.dart';
import 'package:scoreboard_app/TeamCreate.dart';

class LeagueView extends StatefulWidget {
  @override
  State<LeagueView> createState() => _LeagueViewState();
}
// Class to display the league view with separate team and player management
class _LeagueViewState extends State<LeagueView> {
  var selectedIndex = 0;
  bool isTeamCreate = true;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppData>();
    Widget page;
    final teams = appState.teams;
    void flipMenu() {
      setState(() {
        isTeamCreate = !isTeamCreate;
      });
    }
    // Determines whether team or player creation page is shown with selected team
    if (isTeamCreate) {
      page = TeamCreate(
        key: ValueKey('team-$selectedIndex'),
        index: selectedIndex,
        onAddPlayers: flipMenu,
      );
    } else {
      page = PlayerCreateMenu(
        key: ValueKey('player-$selectedIndex'),
        teamId: teams[selectedIndex].id,
        onBack: flipMenu,
      );
    }
    return LayoutBuilder(
      builder: (context, snapshot) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 234, 221, 188),
                actions: [
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainMenu()),
                      );
                    },
                  ),
                ],
              ),
              body: Row(
                children: [
                  SafeArea(
                    child: NavigationRail(
                      extended: constraints.maxWidth >= 600,
                      destinations: [
                        for (final team in teams)
                          NavigationRailDestination(
                            icon: Icon(Icons.group),
                            label: Text(team.name),
                          )
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) {
                        setState(() {
                          selectedIndex = value;
                          isTeamCreate = true;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: page,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
