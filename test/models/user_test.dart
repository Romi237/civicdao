import 'package:flutter_test/flutter_test.dart';
import 'package:civicdao_new/models/user.dart';

void main() {
  group('User model', () {

    User make({String role = 'member', List<String>? voted}) => User(
          id:             'u1',
          email:          'alice@test.com',
          name:           'Alice Dupont',
          role:           role,
          joinDate:       DateTime(2024, 1, 1),
          votedProposals: voted,
        );

    // ── Construction ──────────────────────────────────────────────────────
    test('creates with default member role and empty votedProposals', () {
      final u = make();
      expect(u.role,           'member');
      expect(u.isActive,       true);
      expect(u.votedProposals, isEmpty);
    });

    // ── Role helpers ──────────────────────────────────────────────────────
    test('isAdmin is true for admin role', () {
      expect(make(role: 'admin').isAdmin, true);
    });

    test('isAdmin is false for member role', () {
      expect(make().isAdmin, false);
    });

    // ── Voting helpers ────────────────────────────────────────────────────
    test('canVoteOn returns true before voting', () {
      expect(make().canVoteOn('p1'), true);
    });

    test('canVoteOn returns false after voting', () {
      expect(make(voted: ['p1']).canVoteOn('p1'), false);
    });

    // ── Immutability ──────────────────────────────────────────────────────
    test('copyWithVote adds proposal without mutating original', () {
      final original = make();
      final updated  = original.copyWithVote('p1');
      expect(updated.votedProposals,  contains('p1'));
      expect(original.votedProposals, isEmpty); // original unchanged
    });

    test('copyWith updates only specified fields', () {
      final u    = make();
      final copy = u.copyWith(name: 'Bob', role: 'admin');
      expect(copy.name,  'Bob');
      expect(copy.role,  'admin');
      expect(copy.email, u.email); // unchanged
      expect(u.name,     'Alice Dupont'); // original unchanged
    });

    // ── Display helpers ───────────────────────────────────────────────────
    test('displayName returns first name', () {
      expect(make().displayName, 'Alice');
    });

    test('displayName falls back to email prefix when name is empty', () {
      final u = User(id: '1', email: 'bob@test.com', name: '',
          joinDate: DateTime.now());
      expect(u.displayName, 'bob');
    });

    test('initials returns two-letter initials from full name', () {
      expect(make().initials, 'AD');
    });

    // ── JSON round-trip ───────────────────────────────────────────────────
    test('toJson / fromJson round-trip preserves all fields', () {
      final u       = make(role: 'admin', voted: ['p1', 'p2']);
      final decoded = User.fromJson(u.toJson());
      expect(decoded.id,             u.id);
      expect(decoded.email,          u.email);
      expect(decoded.role,           u.role);
      expect(decoded.votedProposals, u.votedProposals);
    });

    test('fromJson handles _id field from MongoDB', () {
      final u = User.fromJson({
        '_id': 'mongo-id', 'email': 'x@y.com', 'name': 'X',
        'joinDate': '2024-01-01T00:00:00.000', 'isActive': true,
        'votedProposals': [],
      });
      expect(u.id, 'mongo-id');
    });
  });
}
