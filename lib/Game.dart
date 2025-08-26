import 'package:scoreboard_app/PlayerStats.dart';

class Game {
  String id;
  String slateId;
  String teamAId;
  String teamBId;
  DateTime gameDate;
  bool hasStarted;
  bool isCompleted;
  int scoreA;
  int scoreB;
  int quarter;
  Duration timeLeft;
  Map<String, PlayerStats> playerStats;
  int teamATimeouts;
  int teamBTimeouts;
  int teamAFouls;
  int teamBFouls;

  Game({
    required this.id,
    required this.slateId,
    required this.teamAId,
    required this.teamBId,
    required this.gameDate,
    this.hasStarted = false,
    this.isCompleted = false,
    this.scoreA = 0,
    this.scoreB = 0,
    this.quarter = 1,
    this.timeLeft = const Duration(seconds: 4),
    this.playerStats = const {},
    this.teamATimeouts = 2,
    this.teamBTimeouts = 2,
    this.teamAFouls = 0,
    this.teamBFouls = 0,
  });

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'],
        slateId: json['slate_id'],
        teamAId: json['team_a_id'],
        teamBId: json['team_b_id'],
        gameDate: DateTime.parse(json['game_date']),
        hasStarted: json['has_started'],
        isCompleted: json['is_completed'],
        scoreA: json['score_a'],
        scoreB: json['score_b'],
        quarter: json['quarter'],
        timeLeft: Duration(seconds: json['time_left_seconds']),
        playerStats: (json['player_stats'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, PlayerStats.fromJson(v)),
            ) ??
            {},
        teamATimeouts: json['team_a_timeouts'],
        teamBTimeouts: json['team_b_timeouts'],
        teamAFouls: json['team_a_fouls'],
        teamBFouls: json['team_b_fouls'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'slate_id': slateId,
        'team_a_id': teamAId,
        'team_b_id': teamBId,
        'game_date': gameDate.toIso8601String(),
        'has_started': hasStarted,
        'is_completed': isCompleted,
        'score_a': scoreA,
        'score_b': scoreB,
        'quarter': quarter,
        'time_left_seconds': timeLeft.inSeconds,
        'player_stats': playerStats.map((k, v) => MapEntry(k, v.toJson())),
        'team_a_timeouts': teamATimeouts,
        'team_b_timeouts': teamBTimeouts,
        'team_a_fouls': teamAFouls,
        'team_b_fouls': teamBFouls,
      };
}
