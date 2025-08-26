import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoreboard_app/Game.dart';
import 'package:scoreboard_app/League.dart';
import 'package:scoreboard_app/Player.dart';
import 'package:scoreboard_app/ScheduleSlate.dart';
import 'package:scoreboard_app/TeamData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

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
