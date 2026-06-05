import 'package:flutter_test/flutter_test.dart';
import 'package:civicdao_new/models/proposal.dart';

void main() {
  group('Proposal model', () {

    Proposal make({
      ProposalStatus status = ProposalStatus.pending,
      int yes = 0, int no = 0, int total = 0,
      DateTime? endDate,
    }) =>
        Proposal(
          id:              'p1',
          title:           'Test Proposal',
          description:     'A description',
          requestedBudget: 1000,
          authorId:        'u1',
          authorName:      'Alice',
          createdAt:       DateTime(2024, 1, 1),
          status:          status,
          yesVotes:        yes,
          noVotes:         no,
          totalVotes:      total,
          voteEndDate:     endDate,
        );

    // ── Construction ──────────────────────────────────────────────────────
    test('creates with default values', () {
      final p = make();
      expect(p.status,     ProposalStatus.pending);
      expect(p.yesVotes,   0);
      expect(p.noVotes,    0);
      expect(p.totalVotes, 0);
      expect(p.category,   'General');
    });

    // ── Status helpers ────────────────────────────────────────────────────
    test('isActive is true only for voting status', () {
      expect(make(status: ProposalStatus.voting).isActive,   true);
      expect(make(status: ProposalStatus.pending).isActive,  false);
      expect(make(status: ProposalStatus.accepted).isActive, false);
    });

    test('hasEnded is true for accepted and rejected', () {
      expect(make(status: ProposalStatus.accepted).hasEnded, true);
      expect(make(status: ProposalStatus.rejected).hasEnded, true);
      expect(make(status: ProposalStatus.voting).hasEnded,   false);
    });

    // ── Vote percentages ──────────────────────────────────────────────────
    test('forPct and againstPct are 0 when no votes cast', () {
      expect(make().forPct,     0);
      expect(make().againstPct, 0);
    });

    test('forPct is 70 for 7 yes / 3 no out of 10', () {
      expect(make(yes: 7, no: 3, total: 10).forPct, 70);
    });

    test('againstPct is 30 for 3 no out of 10', () {
      expect(make(yes: 7, no: 3, total: 10).againstPct, 30);
    });

    test('abstainPct fills remainder to 100', () {
      final p = make(yes: 6, no: 3, total: 10);
      expect(p.forPct + p.againstPct + p.abstainPct, 100);
    });

    // ── Deadline helpers ──────────────────────────────────────────────────
    test('daysRemaining is -1 when no end date', () {
      expect(make().daysRemaining, -1);
    });

    test('daysRemaining is 0 for a past deadline', () {
      final p = make(endDate: DateTime.now().subtract(const Duration(days: 1)));
      expect(p.daysRemaining, 0);
    });

    test('timeLabel says Ended for past deadline', () {
      final p = make(endDate: DateTime.now().subtract(const Duration(hours: 1)));
      expect(p.timeLabel, 'Ended');
    });

    // ── copyWith ──────────────────────────────────────────────────────────
    test('copyWith preserves unchanged fields', () {
      final p    = make();
      final copy = p.copyWith(title: 'New Title');
      expect(copy.title,           'New Title');
      expect(copy.requestedBudget, p.requestedBudget); // unchanged
    });

    // ── JSON round-trip ───────────────────────────────────────────────────
    test('fromJson deserialises all fields correctly', () {
      final json = {
        '_id': 'abc', 'title': 'Road Repair', 'description': 'Fix roads',
        'requestedBudget': 5000, 'authorId': 'u1', 'authorName': 'Bob',
        'createdAt': '2024-03-01T00:00:00.000', 'status': 'voting',
        'yesVotes': 5, 'noVotes': 2, 'totalVotes': 7, 'category': 'Infrastructure',
      };
      final p = Proposal.fromJson(json);
      expect(p.id,     'abc');
      expect(p.status, ProposalStatus.voting);
      expect(p.yesVotes, 5);
    });

    test('fromJson defaults unknown status to pending', () {
      final p = Proposal.fromJson({
        '_id': 'x', 'title': 'T', 'description': 'D',
        'requestedBudget': 0, 'authorId': 'u', 'authorName': 'A',
        'createdAt': '2024-01-01T00:00:00.000', 'status': 'unknown',
      });
      expect(p.status, ProposalStatus.pending);
    });

    // ── Status enum labels ────────────────────────────────────────────────
    test('status labels match UI strings', () {
      expect(ProposalStatus.pending.label,  'Upcoming');
      expect(ProposalStatus.voting.label,   'Active');
      expect(ProposalStatus.accepted.label, 'Passed');
      expect(ProposalStatus.rejected.label, 'Failed');
    });
  });
}
