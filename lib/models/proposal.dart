enum ProposalStatus { pending, voting, accepted, rejected }

extension ProposalStatusExt on ProposalStatus {
  String get label {
    switch (this) {
      case ProposalStatus.pending:
        return 'Upcoming';
      case ProposalStatus.voting:
        return 'Active';
      case ProposalStatus.accepted:
        return 'Passed';
      case ProposalStatus.rejected:
        return 'Failed';
    }
  }

  String get apiValue {
    switch (this) {
      case ProposalStatus.pending:
        return 'pending';
      case ProposalStatus.voting:
        return 'voting';
      case ProposalStatus.accepted:
        return 'accepted';
      case ProposalStatus.rejected:
        return 'rejected';
    }
  }
}

class Proposal {
  final String id;
  final String title;
  final String description;
  final double requestedBudget;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? voteEndDate;
  final ProposalStatus status;
  final int yesVotes;
  final int noVotes;
  final int totalVotes;
  final String category;

  const Proposal({
    required this.id,
    required this.title,
    required this.description,
    required this.requestedBudget,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.voteEndDate,
    this.status = ProposalStatus.pending,
    this.yesVotes = 0,
    this.noVotes = 0,
    this.totalVotes = 0,
    this.category = 'General',
  });

  bool get isActive => status == ProposalStatus.voting;
  bool get hasEnded =>
      status == ProposalStatus.accepted || status == ProposalStatus.rejected;

  // Percentages for the VoteProgressBar widget (0-100 ints)
  int get forPct =>
      totalVotes > 0 ? ((yesVotes / totalVotes) * 100).round() : 0;
  int get againstPct =>
      totalVotes > 0 ? ((noVotes / totalVotes) * 100).round() : 0;
  int get abstainPct => 100 - forPct - againstPct;

  // Deadline display for the UI
  int get daysRemaining {
    if (voteEndDate == null) return -1;
    final diff = voteEndDate!.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return diff.inDays;
  }

  String get timeLabel {
    if (voteEndDate == null) return 'No deadline';
    final diff = voteEndDate!.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    if (diff.inDays > 0) return 'Ends in ${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return 'Ends in ${diff.inHours}h';
    return 'Ends soon';
  }

  Proposal copyWith({
    String? id,
    String? title,
    String? description,
    double? requestedBudget,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? voteEndDate,
    ProposalStatus? status,
    int? yesVotes,
    int? noVotes,
    int? totalVotes,
    String? category,
  }) {
    return Proposal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      requestedBudget: requestedBudget ?? this.requestedBudget,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      voteEndDate: voteEndDate ?? this.voteEndDate,
      status: status ?? this.status,
      yesVotes: yesVotes ?? this.yesVotes,
      noVotes: noVotes ?? this.noVotes,
      totalVotes: totalVotes ?? this.totalVotes,
      category: category ?? this.category,
    );
  }

  // Convert to the Map shape the existing UI expects
  Map<String, dynamic> toUiMap() => {
        'id': id,
        'title': title,
        'desc': description,
        'status': status.label,
        'time': timeLabel,
        'for': forPct,
        'against': againstPct,
        'abstain': abstainPct,
        'budget': requestedBudget,
        'author': authorName,
        'category': category,
        'rawStatus': status.apiValue,
      };

  factory Proposal.fromJson(Map<String, dynamic> json) => Proposal(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        requestedBudget: (json['requestedBudget'] as num?)?.toDouble() ?? 0,
        authorId: (json['authorId'] ?? '').toString(),
        authorName: json['authorName'] ?? 'Unknown',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        voteEndDate: json['voteEndDate'] != null
            ? DateTime.tryParse(json['voteEndDate'])
            : null,
        status: _statusFrom(json['status']),
        yesVotes: (json['yesVotes'] as num?)?.toInt() ?? 0,
        noVotes: (json['noVotes'] as num?)?.toInt() ?? 0,
        totalVotes: (json['totalVotes'] as num?)?.toInt() ?? 0,
        category: json['category'] ?? 'General',
      );

  static ProposalStatus _statusFrom(dynamic raw) {
    switch ((raw ?? '').toString().toLowerCase()) {
      case 'voting':
        return ProposalStatus.voting;
      case 'accepted':
        return ProposalStatus.accepted;
      case 'rejected':
        return ProposalStatus.rejected;
      default:
        return ProposalStatus.pending;
    }
  }
}
