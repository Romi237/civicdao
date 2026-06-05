class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final DateTime joinDate;
  final bool isActive;
  final List<String> votedProposals;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'member',
    required this.joinDate,
    this.isActive = true,
    List<String>? votedProposals,
  }) : votedProposals = votedProposals ?? const [];

  bool get isAdmin => role == 'admin';
  bool canVoteOn(String proposalId) => !votedProposals.contains(proposalId);

  String get displayName =>
      name.trim().isNotEmpty ? name.trim().split(' ').first : email.split('@').first;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return email[0].toUpperCase();
  }

  User copyWithVote(String proposalId) =>
      copyWith(votedProposals: [...votedProposals, proposalId]);

  User copyWith({
    String? id, String? email, String? name, String? role,
    DateTime? joinDate, bool? isActive, List<String>? votedProposals,
  }) =>
      User(
        id:             id             ?? this.id,
        email:          email          ?? this.email,
        name:           name           ?? this.name,
        role:           role           ?? this.role,
        joinDate:       joinDate       ?? this.joinDate,
        isActive:       isActive       ?? this.isActive,
        votedProposals: votedProposals ?? this.votedProposals,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'email': email, 'name': name, 'role': role,
        'joinDate': joinDate.toIso8601String(),
        'isActive': isActive, 'votedProposals': votedProposals,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id:    (json['id'] ?? json['_id'] ?? '').toString(),
        email: json['email'] ?? '',
        name:  json['name']  ?? '',
        role:  json['role']  ?? 'member',
        joinDate: json['joinDate'] != null
            ? DateTime.tryParse(json['joinDate']) ?? DateTime.now()
            : DateTime.now(),
        isActive: json['isActive'] ?? true,
        votedProposals: (json['votedProposals'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is User && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
