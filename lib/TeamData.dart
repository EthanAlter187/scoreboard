import 'package:flutter/material.dart';

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
