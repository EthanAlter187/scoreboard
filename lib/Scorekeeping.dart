import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoreboard_app/BoxScore.dart';
import 'package:scoreboard_app/Game.dart';
import 'package:scoreboard_app/MyAppData.dart';
import 'package:scoreboard_app/Player.dart';
import 'package:scoreboard_app/PlayerStats.dart';
import 'package:scoreboard_app/TeamData.dart';
import 'package:scoreboard_app/main.dart';

class Scorekeeping extends StatefulWidget {
  final Game game;
  final TeamData teamA;
  final TeamData teamB;

  Scorekeeping({required this.game, required this.teamA, required this.teamB});

  @override
  ScorekeepingState createState() => ScorekeepingState();
}

/* Class to manage scorekeeping during a game. Handles game clock, timeouts, and 
allows switching between teams and updating player stats like points, rebounds,
assists and fouls*/
class ScorekeepingState extends State<Scorekeeping> {
  bool showingTeamA = true;
  bool isClockRunning = false;
  Map<String, bool> isIncr = {};
  Timer? _timer;
  List<Player> _players = []; 
  bool _loadingPlayers = true;

  @override
  void initState() {
    super.initState();
    _timer = null;
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final teamId = showingTeamA ? widget.teamA.id : widget.teamB.id;
    setState(() => _loadingPlayers = true);
    _players = await context.read<MyAppData>().getTeamPlayers(teamId);
    setState(() => _loadingPlayers = false);
  }
  void _switchTeam() {
    setState(() => showingTeamA = !showingTeamA);
    _loadPlayers();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  void toggleClock() {
    final settings = context.read<MyAppData>();
    setState(() {
      if (!widget.game.hasStarted) {
        widget.game.hasStarted = true;
      }
      isClockRunning = !isClockRunning;
      if (!isClockRunning) {
        _timer?.cancel();
      } else if (!widget.game.isCompleted) {
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (widget.game.timeLeft.inSeconds > 0) {
            setState(() {
              widget.game.timeLeft -= Duration(seconds: 1);
            });
            // context.read<MyAppData>().updateGame(widget.game);
          } else {
            timer.cancel();
            setState(() {
              isClockRunning = false;
              if (widget.game.quarter < 4) {
                widget.game.quarter++;
                widget.game.timeLeft = Duration(minutes: settings.quarterLength);
                widget.game.teamATimeouts = settings.timeouts;
                widget.game.teamBTimeouts = settings.timeouts;
                widget.game.teamAFouls = 0;
                widget.game.teamBFouls = 0;
              } else if (widget.game.scoreA == widget.game.scoreB) {
                widget.game.quarter++;
                widget.game.timeLeft = Duration(minutes: (settings.quarterLength)~/2);
                widget.game.teamATimeouts = settings.timeouts~/2;
                widget.game.teamBTimeouts = settings.timeouts~/2;
                widget.game.teamAFouls = 0;
                widget.game.teamBFouls = 0;
              } else {
                widget.game.isCompleted = true;
                context.read<MyAppData>().updateGameStats(widget.game, widget.teamA, widget.teamB);
              }
            });
            context.read<MyAppData>().updateGame(widget.game);
          }
        });
      }
    });
    // context.read<MyAppData>().updateGame(widget.game);
  }

  void updateStat(String playerId, String stat) async {
    setState(() {
      widget.game.playerStats.putIfAbsent(playerId, () => PlayerStats());
      bool isIncrement = isIncr[playerId] ?? true;
      switch (stat) {
        case 'Pts':
          widget.game.playerStats[playerId]!.points += isIncrement ? 1 : -1;
          if (showingTeamA) {
            widget.game.scoreA += isIncrement ? 1 : -1;
          } else {
            widget.game.scoreB += isIncrement ? 1 : -1;
          }
        case 'Reb':
          widget.game.playerStats[playerId]!.rebounds += isIncrement ? 1 : -1;
        case 'Ast':
          widget.game.playerStats[playerId]!.assists += isIncrement ? 1 : -1;
        case 'PF':
          widget.game.playerStats[playerId]!.fouls += isIncrement ? 1 : -1;
          if (isIncrement) {
            if (showingTeamA) {
              widget.game.teamAFouls++;
            } else {
              widget.game.teamBFouls++;
            }
          } else {
            if (showingTeamA) {
              widget.game.teamAFouls = (widget.game.teamAFouls - 1).clamp(0, 100);
            } else {
              widget.game.teamBFouls = (widget.game.teamBFouls - 1).clamp(0, 100);
            }
          }
      }
    });
    // await context.read<MyAppData>().updateGame(widget.game);
  }

  @override
  Widget build(BuildContext context) {
    final data = context.read<MyAppData>();
    if (_loadingPlayers) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: Text('Scorekeeper')),
      body: Column(
        children: [
          Card(
            child: Column(
              children: [
                if (!widget.game.isCompleted)
                  Text(
                    widget.game.timeLeft.toString().substring(2, 7),
                    style: TextStyle(fontSize: 24),
                  )
                else
                  Text("Final", style: TextStyle(fontSize: 24)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(widget.teamA.name,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Timeouts: ${widget.game.teamATimeouts}'),
                        Text('Fouls: ${widget.game.teamAFouls}'),
                        if (!widget.game.isCompleted && data.isAdmin)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (widget.game.teamATimeouts > 0) {
                                widget.game.teamATimeouts--;
                                isClockRunning = false;
                                _timer?.cancel();
                              }
                            });
                            context.read<MyAppData>().updateGame(widget.game);
                          },
                          child: Text('Timeout'),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        if (!widget.game.isCompleted)
                          Text(
                              widget.game.quarter < 5
                                  ? 'Q${widget.game.quarter}'
                                  : 'O${widget.game.quarter - 4}',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('vs.'),
                        Text(
                            '${widget.game.hasStarted ? widget.game.scoreA : '-'} - ${widget
                            .game.hasStarted ? widget.game.scoreB : '-'}',
                            style: TextStyle(fontSize: 30)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(widget.teamB.name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Timeouts: ${widget.game.teamBTimeouts}'),
                        Text('Fouls: ${widget.game.teamBFouls}'),
                        if (!widget.game.isCompleted && data.isAdmin)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (widget.game.teamBTimeouts > 0) {
                                  widget.game.teamBTimeouts--;
                                  isClockRunning = false;
                                  _timer?.cancel();
                                }
                              });
                              context.read<MyAppData>().updateGame(widget.game);
                            },
                            child: Text('Timeout'),
                          ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!widget.game.isCompleted && data.isAdmin)
                ElevatedButton(
                  onPressed: toggleClock,
                  child: Text(isClockRunning ? 'Stop Clock' : 'Start Clock'),
                ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _switchTeam,
                child: Text('Switch Team'),
              ),
            ],
          ),
          Expanded(
            child: !widget.game.isCompleted && data.isAdmin
                ? ListView.builder(
                    itemCount: _players.length,
                    itemBuilder: (context, index) {
                      final player = _players[index];
                      final stats = widget.game.playerStats[player.id] ?? PlayerStats();
                      return ListTile(
                        title: Text('${player.name} (#${player.jerseyNumber})'),
                        subtitle: Text(
                          'Pts: ${stats.points}, Reb: ${stats.
                          rebounds}, Ast: ${stats.assists}, PF: ${stats.fouls}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                (isIncr[player.id] ?? true)
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                              ),
                              onPressed: () {
                                setState(() {
                                  isIncr[player.id] = !(isIncr[player.id] ?? true);
                                });
                              },
                            ),
                            ...['Pts', 'Reb', 'Ast', 'PF'].map((s) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: ElevatedButton(
                                    onPressed: () => updateStat(player.id, s),
                                    child: Text(s),
                                  ),
                                )),
                          ],
                        ),
                      );
                    },
                  )
                : BoxScore(
                    players: _players,
                    stats: widget.game.playerStats,
                  ),
          ),
        ],
      ),
    );
  }
}
