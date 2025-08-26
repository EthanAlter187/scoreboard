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
