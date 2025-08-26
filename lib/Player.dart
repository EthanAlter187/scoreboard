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
