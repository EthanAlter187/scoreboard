import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ldbkhcfhumtyvlqjndcl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxkYmtoY2ZodW10eXZscWpuZGNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM4MDg3NTgsImV4cCI6MjA2OTM4NDc1OH0.vfjLpTax82Xu9zR6UvmBkfiPUXdPMJ2drN_02ks8gv0',
  );
  runApp(MyApp());
}

// Sets up main app widget with a ChangeNotifierProvider and custom theme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Scoreboard',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 211, 148, 53),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFA726), brightness: Brightness.light
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.black, 
            selectionColor: Colors.black26, 
            selectionHandleColor: Colors.black,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.black), 
            labelStyle: TextStyle(color: Colors.black), 
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

// Custom text field widget with input validation and formatting
class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    required this.controller,
    required this.isNumeric,
    required this.label,
  });

  final TextEditingController controller;
  final bool isNumeric;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 40,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: const Color.fromARGB(255, 215, 214, 214),
      ),
      inputFormatters: [
        if (isNumeric) FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

// OutlinedText widget for outlined app title
class OutlinedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fillColor;
  final Color outlineColor;
  final double strokeWidth;

  const OutlinedText({
    required this.text,
    required this.fontSize,
    required this.fillColor,
    required this.outlineColor,
    this.strokeWidth = 3.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = outlineColor,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: fillColor,
          ),
        ),
      ],
    );
  }
}

// AuthWrapper widget that checks auth state and navigates to appropriate page
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (supabase.auth.currentUser == null) {
          return LoginPage();
        }
        return HomePage();
      },
    );
  }
}

// LoginPage widget for user authentication
class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextField(
                  controller: emailController,
                  isNumeric: false,
                  label: 'Email',
                ),
                MyTextField(
                  controller: passwordController,
                  isNumeric: false,
                  label: 'Password',
                ),
                const SizedBox(height: 16),
                // validates login
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.auth.signInWithPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login failed: $e')),
                      );
                    }
                  },
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.auth.signUp(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign up failed: $e')),
                      );
                    }
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Data classes for Teams, Players, PlayerStats, Games, ScheduleSlates, and League
class TeamData {
  String id;
  String leagueId;
  String name;
  String color;
  int wins;
  int losses;
  int totalPoints;
  int pointDiff;

  TeamData({
    required this.id,
    required this.leagueId,
    required this.name,
    this.color = '#0000FF',
    this.wins = 0,
    this.losses = 0,
    this.totalPoints = 0,
    this.pointDiff = 0,
  });
  // each retrieval and update from/to Supabase must be converted to/from JSON
  factory TeamData.fromJson(Map<String, dynamic> json) => TeamData(
        id: json['id'],
        leagueId: json['league_id'],
        name: json['name'],
        color: json['color'],
        wins: json['wins'],
        losses: json['losses'],
        totalPoints: json['total_points'],
        pointDiff: json['point_diff'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'league_id': leagueId,
        'name': name,
        'color': color,
        'wins': wins,
        'losses': losses,
        'total_points': totalPoints,
        'point_diff': pointDiff,
      };

  Color hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add full opacity if not provided
    }
    return Color(int.parse(hex, radix: 16));
  }
  Color get colorValue => hexToColor(color);
  int get gamesPlayed => wins + losses;
}

class Player {
  String id;
  String teamId;
  String name;
  int jerseyNumber;
  int age;
  int totalPoints;
  int totalRebounds;
  int totalAssists;
  int totalFouls;
  int games;

  Player({
    required this.id,
    required this.teamId,
    required this.name,
    required this.jerseyNumber,
    required this.age,
    this.totalPoints = 0,
    this.totalRebounds = 0,
    this.totalAssists = 0,
    this.totalFouls = 0,
    this.games = 0,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'],
        teamId: json['team_id'],
        name: json['name'],
        jerseyNumber: json['jersey_number'],
        age: json['age'],
        totalPoints: json['total_points'],
        totalRebounds: json['total_rebounds'],
        totalAssists: json['total_assists'],
        totalFouls: json['total_fouls'],
        games: json['games'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'team_id': teamId,
        'name': name,
        'jersey_number': jerseyNumber,
        'age': age,
        'total_points': totalPoints,
        'total_rebounds': totalRebounds,
        'total_assists': totalAssists,
        'total_fouls': totalFouls,
        'games': games,
      };
}

class PlayerStats {
  int points = 0;
  int rebounds = 0;
  int assists = 0;
  int fouls = 0;

  PlayerStats();

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats()
    ..points = json['points']
    ..rebounds = json['rebounds']
    ..assists = json['assists']
    ..fouls = json['fouls'];

  Map<String, dynamic> toJson() => {
        'points': points,
        'rebounds': rebounds,
        'assists': assists,
        'fouls': fouls,
      };
}

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

class ScheduleSlate {
  String id;
  String leagueId;
  String name;

  ScheduleSlate({
    required this.id,
    required this.leagueId,
    required this.name,
  });

  factory ScheduleSlate.fromJson(Map<String, dynamic> json) => ScheduleSlate(
        id: json['id'],
        leagueId: json['league_id'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'league_id': leagueId,
        'name': name,
      };
}

class League {
  String id;
  String name;
  String inviteCode;

  League({
    required this.id,
    required this.name,
    required this.inviteCode,
  });

  factory League.fromJson(Map<String, dynamic> json) => League(
        id: json['id'],
        name: json['name'],
        inviteCode: json['invite_code'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'invite_code': inviteCode,
      };
}
// Class to manages local app state, interacts with Supabase, and provides data to the UI
class MyAppData extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  String? _currentLeagueId;
  List<TeamData> _teams = [];
  List<ScheduleSlate> _scheduleSlates = [];
  List<Game> _games = [];
  int _quarterLength = 12;
  int _timeouts = 2;
  bool _isAdmin = true;

  String? get currentLeagueId => _currentLeagueId;
  List<TeamData> get teams => _teams;
  List<ScheduleSlate> get slates => _scheduleSlates;
  List<Game> get games => _games;
  int get quarterLength => _quarterLength;
  int get timeouts => _timeouts;
  bool get isAdmin => _isAdmin;

  MyAppData() {
    initCurrentLeague();
  }
  // Initializes the current league based on the authenticated user
  Future<void> initCurrentLeague() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final res = await supabase
      .from('league_users')
      .select('league_id')
      .eq('user_id', user.id);
    if (res.isNotEmpty) {
      _currentLeagueId = res.first['league_id'];
      await _loadLeagueData();
    }
    notifyListeners();
  }
  // Updates the league name in the database
  Future<void> updateLeagueName(String newName) async {
    await supabase.from('leagues').update({'name': newName}).eq('id', _currentLeagueId!);
    notifyListeners();
  }
  // Updates the game settings such as quarter length and timeouts
  Future<void> updateGameSettings(int quarterLength, int timeouts) async {
    await supabase
      .from('settings')
      .update({
        'quarter_length': quarterLength,
        'timeouts_per_quarter': timeouts,
      })
      .eq('league_id', _currentLeagueId!);
    _quarterLength = quarterLength;
    _timeouts = timeouts;
    final newDuration = Duration(minutes: quarterLength);
    for (var game in _games) {
      if (!game.hasStarted) {
        game.timeLeft = newDuration;
        game.teamATimeouts = timeouts;
        game.teamBTimeouts = timeouts;
      }
    }
    notifyListeners();
  }
  // Retrieves the current league details
  Future<League> getCurrentLeague() async {
    if (_currentLeagueId == null) throw Exception('No league selected');
    final response = await supabase
        .from('leagues')
        .select()
        .eq('id', _currentLeagueId!)
        .single();
    return League.fromJson(response);
  }
  // Creates a new league with the specified name and team count
  Future<void> createLeague(String name, int teamCount) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final leagueId = Uuid().v4();
    final inviteCode = Uuid().v4().substring(0, 6);

    await supabase.from('leagues').insert({
      'id': leagueId,
      'name': name,
      'creator_id': user.id,
      'invite_code': inviteCode,
    });

    await supabase.from('league_users').insert({
      'league_id': leagueId,
      'user_id': user.id,
      'role': 'admin',
    });

    await supabase.from('settings').insert({
    'league_id': leagueId,
    'quarter_length': 12,
    'timeouts_per_quarter': 2,
  });

    _currentLeagueId = leagueId;
    _teams = List.generate(
      teamCount,
      (index) => TeamData(
        id: Uuid().v4(),
        leagueId: leagueId,
        name: 'Team ${index + 1}',
      ),
    );

    for (var team in _teams) {
      await supabase.from('teams').insert(team.toJson());
    }

    await initSchedule();
    notifyListeners();
  }
  // Creates or updates a team in the current league
  Future<void> createTeam(int index, String name, Color color) async {
    if (_currentLeagueId == null || index >= _teams.length) return;
    final team = _teams[index];
    team.name = name;
    team.color = '#${color.value.toRadixString(16).padLeft(8, '0')}';
    await supabase
        .from('teams')
        .update(team.toJson())
        .eq('id', team.id);
    notifyListeners();
  }
  // Joins a league using the provided invite code
  Future<void> joinLeague(String inviteCode) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('leagues')
        .select()
        .eq('invite_code', inviteCode)
        .single();

    if (response.isEmpty) throw Exception('Invalid invite code');

    _currentLeagueId = response['id'];
    await supabase.from('league_users').insert({
      'league_id': _currentLeagueId,
      'user_id': user.id,
      'role': 'guest',
    });
    _isAdmin = false;
    await _loadLeagueData();
    notifyListeners();
  }
  // Loads league data including teams, schedule slates, and games
  Future<void> _loadLeagueData() async {
    if (_currentLeagueId == null) return;

    // Load teams for the current league
    final teamsResponse = await supabase
        .from('teams')
        .select()
        .eq('league_id', _currentLeagueId!);

    _teams = teamsResponse.map<TeamData>((json) => TeamData.fromJson(json)).toList();

    // Load schedule slates for the current league
    final slatesResponse = await supabase
        .from('schedule_slates')
        .select()
        .eq('league_id', _currentLeagueId!);

    _scheduleSlates = slatesResponse
        .map<ScheduleSlate>((json) => ScheduleSlate(
              id: json['id'],
              leagueId: json['league_id'],
              name: json['name'],
            ))
        .toList();

    // Load all games for this league (by joining slate_ids)
    // Instead of loading per slate, load all games once and keep separately
    final slateIds = _scheduleSlates.map((s) => s.id).toList();

    if (slateIds.isNotEmpty) {
      final gamesResponse = await supabase
          .from('games')
          .select()
          .filter('slate_id', 'in', slateIds);

      _games = gamesResponse.map<Game>((json) => Game.fromJson(json)).toList();
    } else {
      _games = [];
    }

    notifyListeners();
  }
  // Adds a new player to a team in the current league
  Future<void> addPlayer(String teamId, String name, int age, int jersey) async {
    final player = Player(
      id: Uuid().v4(),
      teamId: teamId,
      name: name,
      jerseyNumber: jersey,
      age: age,
    );

    await supabase.from('players').insert(player.toJson());
  }
  // Edits an existing player's details
  Future<void> editPlayer(String playerId, String name, int age, int jersey) async {
    await supabase.from('players').update({
      'name': name,
      'age': age,
      'jersey_number': jersey,
    }).eq('id', playerId);
  }
  // Removes a player from a team in the current league
  Future<void> removePlayer(String teamId, String playerId) async {
    await supabase.from('players').delete().eq('id', playerId);
  }
  // Initializes the schedule with a default slate if none exists
  Future<void> initSchedule() async {
    if (_currentLeagueId == null) return;
    if (_scheduleSlates.isEmpty) {
      final slate = ScheduleSlate(
        id: Uuid().v4(),
        leagueId: _currentLeagueId!,
        name: 'Week 1',
      );
      await supabase.from('schedule_slates').insert(slate.toJson());
      _scheduleSlates.add(slate);
      notifyListeners();
    }
  }
  // Adds a new slate (week) to the schedule
  Future<void> addSlate() async {
    if (_currentLeagueId == null) return;
    final nextNum = _scheduleSlates.length + 1;
    final slate = ScheduleSlate(
      id: Uuid().v4(),
      leagueId: _currentLeagueId!,
      name: 'Week $nextNum',
    );
    await supabase.from('schedule_slates').insert(slate.toJson());
    _scheduleSlates.add(slate);
    notifyListeners();
  }
  // adds a game to a specific slate in the schedule
  Future<void> addGameToSlate(int slateIndex) async {
    if (_currentLeagueId == null || slateIndex >= _scheduleSlates.length) return;
    final game = Game(
      id: Uuid().v4(),
      slateId: _scheduleSlates[slateIndex].id,
      // placeholder until teams are selected (updateGame())
      teamAId: _teams.first.id,
      teamBId: _teams.first.id,
      gameDate: DateTime.now(),
      timeLeft: Duration(minutes: _quarterLength),
      teamATimeouts: _timeouts,
      teamBTimeouts: _timeouts,
    );
    await supabase.from('games').insert(game.toJson());
    _games.add(game);
    notifyListeners();
  }

  // Updates an existing game with new details
  Future<void> updateGame(Game game, {String? teamAId, String? teamBId, DateTime? gameDate}) async {
    final updates = game.toJson();
    if (teamAId != null) updates['team_a_id'] = teamAId;
    if (teamBId != null) updates['team_b_id'] = teamBId;
    if (gameDate != null) updates['game_date'] = gameDate.toIso8601String();

    await supabase.from('games').update(updates).eq('id', game.id);
    await _loadLeagueData();
  }
  // removes a game from a specific slate in the schedule
  Future<void> removeGame(int slateIndex, int gameIndex) async {
    if (slateIndex >= _scheduleSlates.length) return;
    final slateId = _scheduleSlates[slateIndex].id;
    // find the slate in which the game is present
    final slateGames = _games.where((g) => g.slateId == slateId).toList();
    if (gameIndex >= slateGames.length) return;
    final gameId = slateGames[gameIndex].id;
    await supabase.from('games').delete().eq('id', gameId);
    _games.removeWhere((g) => g.id == gameId);
    notifyListeners();
  }
  // retrieves all players for a specific team
  Future<List<Player>> getTeamPlayers(String teamId) async {
    final response = await supabase.from('players').select().eq('team_id', teamId);
    return response.map<Player>((json) => Player.fromJson(json)).toList();
  }
  // retrieves a specific team by its ID
  Future<TeamData> getTeam(String teamId) async {
    final response = await supabase.from('teams').select().eq('id', teamId).single();
    return TeamData.fromJson(response);
  }
  // retrieves all teams in the current league
  Future<List<TeamData>> getTeams() async {
    if (_currentLeagueId == null) return [];
    final response = await supabase.from('teams').select().eq('league_id', _currentLeagueId!);
    return response.map<TeamData>((json) => TeamData.fromJson(json)).toList();
  }
  // retrieves all games in the current league
  Future<void> updateGameStats(Game game, TeamData teamA, TeamData teamB) async {
    if (!game.isCompleted) return;
    for (var playerId in game.playerStats.keys) {
      final stats = game.playerStats[playerId]!;
      final playerData = await supabase
          .from('players')
          .select('total_points, total_rebounds, total_assists, total_fouls, games')
          .eq('id', playerId)
          .single();
      final updatedPlayerData = {
        'total_points': (playerData['total_points'] ?? 0) + stats.points,
        'total_rebounds': (playerData['total_rebounds'] ?? 0) + stats.rebounds,
        'total_assists': (playerData['total_assists'] ?? 0) + stats.assists,
        'total_fouls': (playerData['total_fouls'] ?? 0) + stats.fouls,
        'games': (playerData['games'] ?? 0) + 1,
      };
      await supabase.from('players').update(updatedPlayerData).eq('id', playerId);
    }
    final teamAData = await supabase
        .from('teams')
        .select('total_points, point_diff, wins, losses')
        .eq('id', teamA.id)
        .single();

    await supabase.from('teams').update({
      'total_points': (teamAData['total_points'] ?? 0) + game.scoreA,
      'point_diff': (teamAData['point_diff'] ?? 0) + (game.scoreA - game.scoreB),
      'wins': game.scoreA > game.scoreB ? (teamAData['wins'] ?? 0) + 1 : (teamAData['wins'] ?? 0),
      'losses': game.scoreA < game.scoreB ? (teamAData['losses'] ?? 0) + 1 : (teamAData['losses'] ?? 0),
    }).eq('id', teamA.id);

    final teamBData = await supabase
        .from('teams')
        .select('total_points, point_diff, wins, losses')
        .eq('id', teamB.id)
        .single();

    await supabase.from('teams').update({
      'total_points': (teamBData['total_points'] ?? 0) + game.scoreB,
      'point_diff': (teamBData['point_diff'] ?? 0) + (game.scoreB - game.scoreA),
      'wins': game.scoreB > game.scoreA ? (teamBData['wins'] ?? 0) + 1 : (teamBData['wins'] ?? 0),
      'losses': game.scoreB < game.scoreA ? (teamBData['losses'] ?? 0) + 1 : (teamBData['losses'] ?? 0),
    }).eq('id', teamB.id);

    await _loadLeagueData();
    notifyListeners();
  }
}
// displays the main menu and allows navigation to create/join/continue leagues
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
// Class to create a new league with a name and number of teams
class CreateLeague extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 234, 221, 188),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double fieldWidth = constraints.maxWidth > 600 ? 500 : constraints.maxWidth * 0.8;
          return Center(
            child: SizedBox(
              width: fieldWidth,
              child: CreateCard(),
            ),
          );
        },
      ),
    );
  }
}
// Custom card widget for creating a league on CreaeLeague page
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

// Class to create a team with name and color selection
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
                  int i = entry.key;
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

/* Displays the current league name and options to start a game, view schedule,
edit teams, view stats/standings, and navigate to settings if the user is an admin*/
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

class PlaySchedule extends StatefulWidget {
  const PlaySchedule({super.key});

  @override
  PlayScheduleState createState() => PlayScheduleState();
}

// Class to display the schedule with games for the current week
// Includes play/continue/view button to navigate to scorekeeping for each game
class PlayScheduleState extends State<PlaySchedule> {
  int currentSlateIndex = 0;

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
              ],
            ),
            actions: [
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
              ? Center(child: Text("No games scheduled for this week."))
              : ListView.builder(
                  itemCount: slateGames.length,
                  itemBuilder: (context, index) {
                    final game = slateGames[index];
                    final teamA = teams.firstWhere((t) => t.id == game.teamAId,
                      orElse: () => TeamData(id: '', leagueId: '', name: 'Unknown'));
                    final teamB = teams.firstWhere((t) => t.id == game.teamBId,
                      orElse: () => TeamData(id: '', leagueId: '', name: 'Unknown'));
                    String scoreA = game.hasStarted ? "${game.scoreA}" : "-";
                    String scoreB = game.hasStarted ? "${game.scoreB}" : "-";
                    // button text depends on game status and user permissions
                    String label = !game.hasStarted && data.isAdmin
                        ? "Start"
                        : !game.isCompleted && data.isAdmin
                            ? "Continue"
                            : "View";
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('MMM d, yyyy').format(game.gameDate),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        "${teamA.name} ",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(width: 275),
                                      Text(
                                        scoreA,
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "vs.",
                                  style: TextStyle(fontSize: 18),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        scoreB,
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 275),
                                      Text(
                                        "${teamB.name} ",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 7),
                            if (game.hasStarted)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      !game.isCompleted ? 'Q${game.quarter}' : "Final",
                                      style: TextStyle(fontSize: 16)),
                                  if (!game.isCompleted) SizedBox(width: 12),
                                  if (!game.isCompleted)
                                    Text(game.timeLeft.toString().substring(2, 7),
                                        style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            SizedBox(height: 4),
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Scorekeeping(
                                        game: game,
                                        teamA: teamA,
                                        teamB: teamB,
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                },
                                child: Text(label),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

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
// Box score display for completed games or ongoing games in view mode (not admin)
class BoxScore extends StatelessWidget {
  final List<Player> players;
  final Map<String, PlayerStats> stats;

  const BoxScore({required this.players, required this.stats, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
          child: Row(
            children: const [
              Expanded(flex: 3, child: Text('Player', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
              Expanded(child: Text('PTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
              Expanded(child: Text('REB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
              Expanded(child: Text('AST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
              Expanded(child: Text('PF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
            ],
          ),
        ),
        Divider(thickness: 1),
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              final stat = stats[player.id] ?? PlayerStats();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('${player.name} (#${player.jerseyNumber})', style: TextStyle(fontSize: 22))),
                    Expanded(child: Text(stat.points.toString(), style: TextStyle(fontSize: 22))),
                    Expanded(child: Text(stat.rebounds.toString(), style: TextStyle(fontSize: 22))),
                    Expanded(child: Text(stat.assists.toString(), style: TextStyle(fontSize: 22))),
                    Expanded(child: Text(stat.fouls.toString(), style: TextStyle(fontSize: 22))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  StatsPageState createState() => StatsPageState();
}
/* class to display and filter player stats by team, 
sort option (points, rebounds, assists, fouls), and totals/averages */
class StatsPageState extends State<StatsPage> {
  String selectedTeam = 'All Teams';
  String sortOption = 'A-Z';
  List<Player> displayedPlayers = [];
  bool showAverages = false;

  Future<void> _searchPlayers(MyAppData data) async {
    List<Player> players;
    if (selectedTeam == 'All Teams') {
      final teams = await data.getTeams();
      players = (await Future.wait(teams.map((t) => data.getTeamPlayers(t.id))))
          .expand((p) => p)
          .toList();
    } else {
      final team = (await data.getTeams()).firstWhere((t) => t.name == selectedTeam);
      players = await data.getTeamPlayers(team.id);
    }

    switch (sortOption) {
      case 'A-Z':
        players.sort((a, b) => a.name.compareTo(b.name));
      case 'Z-A':
        players.sort((a, b) => b.name.compareTo(a.name));
      case 'Points':
        players.sort((b, a) => showAverages
            ? (a.totalPoints / (a.games == 0 ? 1 : a.games))
              .compareTo(b.totalPoints / (b.games == 0 ? 1 : b.games))
            : a.totalPoints.compareTo(b.totalPoints));
      case 'Rebounds':
        players.sort((b, a) => showAverages
            ? (a.totalRebounds / (a.games == 0 ? 1 : a.games))
              .compareTo(b.totalRebounds / (b.games == 0 ? 1 : b.games))
            : a.totalRebounds.compareTo(b.totalRebounds));
      case 'Assists':
        players.sort((b, a) => showAverages
            ? (a.totalAssists / (a.games == 0 ? 1 : a.games))
              .compareTo(b.totalAssists / (b.games == 0 ? 1 : b.games))
            : a.totalAssists.compareTo(b.totalAssists));
      case 'Fouls':
        players.sort((b, a) => showAverages
            ? (a.totalFouls / (a.games == 0 ? 1 : a.games))
              .compareTo(b.totalFouls / (b.games == 0 ? 1 : b.games))
            : a.totalFouls.compareTo(b.totalFouls));
    }

    setState(() {
      displayedPlayers = players;
    });
  }

  @override
  Widget build(BuildContext context) {
    final myAppData = context.watch<MyAppData>();
    return FutureBuilder<List<TeamData>>(
      future: myAppData.getTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final teams = snapshot.data ?? [];
        List<String> teamOptions = ['All Teams', ...teams.map((t) => t.name)];
        List<String> sortOptions = ['A-Z', 'Z-A', 'Points', 'Rebounds', 'Assists', 'Fouls'];
        List<String> statModes = ['Totals', 'Averages'];

        if (displayedPlayers.isEmpty) {
          _searchPlayers(myAppData);
        }

        return Scaffold(
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainMenu()),
                      );
                    },
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Standings()),
                      );
                    },
                    child: Text("View Standings"),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Center(
                child: Text('Stats', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 223, 211, 211),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton<String>(
                          value: selectedTeam,
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedTeam = value);
                            }
                          },
                          items: teamOptions
                              .map((team) => DropdownMenuItem<String>(
                                    value: team,
                                    child: Text(team),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 223, 211, 211),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton<String>(
                          value: sortOption,
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => sortOption = value);
                            }
                          },
                          items: sortOptions
                              .map((option) => DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        width: 120,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 223, 211, 211),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton<String>(
                          value: showAverages ? 'Averages' : 'Totals',
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                showAverages = value == 'Averages';
                              });
                            }
                          },
                          items: statModes
                              .map((mode) => DropdownMenuItem<String>(
                                    value: mode,
                                    child: Text(mode),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _searchPlayers(myAppData),
                      child: Text('Search'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: displayedPlayers.length,
                  itemBuilder: (context, index) {
                    final player = displayedPlayers[index];
                    final games = player.games == 0 ? 1 : player.games;
                    return ListTile(
                      title: Text('${player.name} (#${player.jerseyNumber})'),
                      subtitle: showAverages
                          ? Text(
                              'PPG: ${(player.totalPoints / games).toStringAsFixed(1)}, '
                              'RPG: ${(player.totalRebounds / games).toStringAsFixed(1)}, '
                              'APG: ${(player.totalAssists / games).toStringAsFixed(1)}, '
                              'FPG: ${(player.totalFouls / games).toStringAsFixed(1)}')
                          : Text(
                              'Pts: ${player.totalPoints}, Reb: ${player.totalRebounds}, '
                              'Ast: ${player.totalAssists}, PF: ${player.totalFouls}'),
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
// class to display league standings sorted by win percentage and point differential
class Standings extends StatelessWidget {
  const Standings({super.key});

  @override
  Widget build(BuildContext context) {
    final myAppData = context.watch<MyAppData>();
    return FutureBuilder<List<TeamData>>(
      future: myAppData.getTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final teams = snapshot.data ?? [];
        List<TeamData> sortedTeams = [...teams];
        sortedTeams.sort((b, a) {
          double winPctA = a.gamesPlayed == 0 ? 0 : a.wins / a.gamesPlayed;
          double winPctB = b.gamesPlayed == 0 ? 0 : b.wins / b.gamesPlayed;
          return winPctA == winPctB
              ? a.pointDiff.compareTo(b.pointDiff)
              : winPctA.compareTo(winPctB);
        });

        return Scaffold(
          body: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainMenu()),
                      );
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const StatsPage()),
                      );
                    },
                    child: const Text("View Stats"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Standings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
                    Expanded(child: Text('W-L', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
                    Expanded(child: Text('PCT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
                    Expanded(child: Text('PD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedTeams.length,
                  itemBuilder: (context, index) {
                    final team = sortedTeams[index];
                    final winPct = team.gamesPlayed == 0 ? 0.0 : team.wins / team.gamesPlayed;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                      child: Row(
                        children: [
                          Container(width: 12, height: 12,
                            decoration: BoxDecoration(
                              color: team.colorValue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(flex: 3, child: Text(team.name, style: const TextStyle(fontSize: 22))),
                          Expanded(child: Text('${team.wins}-${team.losses}', style: const TextStyle(fontSize: 22))),
                          Expanded(child: Text(winPct.toStringAsFixed(3), style: const TextStyle(fontSize: 22))),
                          Expanded(child: Text(team.pointDiff.toString(), style: const TextStyle(fontSize: 22))),
                        ],
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

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}
// Class to display and edit league settings like name, quarter length, and timeouts
// Also shows invite code with copy button
class _SettingsPageState extends State<SettingsPage> {
  final _leagueNameController = TextEditingController();
  int _quarterLength = 12;
  int _timeoutsPerQuarter = 2;
  String _inviteCode = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final data = context.read<MyAppData>();
    final league = await data.getCurrentLeague();
    setState(() {
      _leagueNameController.text = league.name;
      _inviteCode = league.inviteCode;
      // assume you stored these in MyAppData or defaults
      _quarterLength = data.quarterLength;
      _timeoutsPerQuarter = data.timeouts;
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    final data = context.read<MyAppData>();
    await data.updateLeagueName(_leagueNameController.text);
    await data.updateGameSettings(_quarterLength, _timeoutsPerQuarter);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _leagueNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
            
                  Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  SizedBox(height: 24),

                  Text('League Name', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  TextField(
                    controller: _leagueNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
            
                  Text('Minutes per Quarter', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<int>(
                      isDense: true,
                      value: _quarterLength,
                      items: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16].map((m) => DropdownMenuItem(value: m, child: Text('$m'))).toList(),
                      onChanged: (v) => setState(() => _quarterLength = v!),
                    ),
                  ),
                  SizedBox(height: 24),       

                  Text('Timeouts per Quarter', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<int>(
                      isDense: true,
                      value: _timeoutsPerQuarter,
                      items: [1, 2, 3, 4].map((t) => DropdownMenuItem(value: t, child: Text('$t'))).toList(),
                      onChanged: (v) => setState(() => _timeoutsPerQuarter = v!),
                    ),
                  ),
                  SizedBox(height: 34),
            
                  Row(
                    children: [
                      Expanded(child: Text('Invite Code: $_inviteCode', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      SizedBox(height: 4),
                      IconButton(
                        icon: Icon(Icons.copy),
                        iconSize: 26,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _inviteCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Invite code copied!')),
                          );
                        },
                      ),
                    ],
                  ),
                  Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      child: Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
