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
