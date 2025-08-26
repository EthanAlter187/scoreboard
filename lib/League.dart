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
