import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/proposal.dart';
import '../models/user.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  final AuthService _auth = AuthService();
  static const _timeout = Duration(seconds: 15);

  String get _base =>
      dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:3000/api');

  // ── Core request helper — retries once after silent token refresh ─────────
  Future<http.Response> _req(String method, String path,
      {Map<String, dynamic>? body}) async {
    Future<http.Response> send() {
      final uri = Uri.parse('$_base$path');
      final hdrs = _auth.authHeaders;
      final enc = body != null ? jsonEncode(body) : null;
      switch (method) {
        case 'POST':
          return http.post(uri, headers: hdrs, body: enc).timeout(_timeout);
        case 'PUT':
          return http.put(uri, headers: hdrs, body: enc).timeout(_timeout);
        case 'DELETE':
          return http.delete(uri, headers: hdrs).timeout(_timeout);
        default:
          return http.get(uri, headers: hdrs).timeout(_timeout);
      }
    }

    var res = await send();
    if (res.statusCode == 401) {
      final ok = await _auth.refreshAccessToken();
      if (ok) res = await send();
    }
    return res;
  }

  Map<String, dynamic> _err(http.Response r) {
    try {
      final d = jsonDecode(r.body);
      return {
        'success': false,
        'error': d['error'] ?? 'Error ${r.statusCode}.'
      };
    } catch (_) {
      return {'success': false, 'error': 'Error ${r.statusCode}.'};
    }
  }

  Map<String, dynamic> _netErr() =>
      {'success': false, 'error': 'Network error — check your connection.'};

  // ── Proposals ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getProposals({String? status}) async {
    try {
      final qs = status != null ? '?status=$status' : '';
      final res = await _req('GET', '/proposals$qs');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          'success': true,
          'proposals': (data['proposals'] as List)
              .map((e) => Proposal.fromJson(e))
              .toList(),
        };
      }
      return _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> createProposal({
    required String title,
    required String description,
    required double requestedBudget,
    DateTime? voteEndDate,
    String category = 'General',
  }) async {
    try {
      final res = await _req('POST', '/proposals', body: {
        'title': title,
        'description': description,
        'requestedBudget': requestedBudget,
        'voteEndDate': voteEndDate?.toIso8601String(),
        'category': category,
      });
      if (res.statusCode == 201) {
        return {
          'success': true,
          'proposal': Proposal.fromJson(jsonDecode(res.body))
        };
      }
      return _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> updateProposalStatus(
      String id, String status) async {
    try {
      final res =
          await _req('PUT', '/proposals/$id/status', body: {'status': status});
      if (res.statusCode == 200) {
        return {
          'success': true,
          'proposal': Proposal.fromJson(jsonDecode(res.body))
        };
      }
      return _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  // ── Voting ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> submitVote(String proposalId, bool vote) async {
    try {
      final res = await _req('POST', '/vote',
          body: {'proposalId': proposalId, 'vote': vote});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          'success': true,
          'proposal': Proposal.fromJson(data['proposal'])
        };
      }
      return _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  // ── Treasury ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getTreasury() async {
    try {
      final res = await _req('GET', '/treasury');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          'success': true,
          'balance': (data['balance'] as num?)?.toDouble() ?? 0.0,
          'transactions': data['transactions'] as List? ?? [],
          'totalProposals': data['totalProposals'] ?? 0,
          'activeProposals': data['activeProposals'] ?? 0,
          'totalMembers': data['totalMembers'] ?? 0,
        };
      }
      return _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> addTransaction({
    required String type,
    required double amount,
    required String description,
  }) async {
    try {
      final res = await _req('POST', '/treasury',
          body: {'type': type, 'amount': amount, 'description': description});
      if (res.statusCode == 201) return {'success': true};
      return _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  // ── Users ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getUsers() async {
    try {
      final res = await _req('GET', '/users');
      if (res.statusCode == 200) {
        return {
          'success': true,
          'users': (jsonDecode(res.body) as List)
              .map((e) => User.fromJson(e))
              .toList(),
        };
      }
      return _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final res = await _req('GET', '/notifications');
      if (res.statusCode == 200) {
        return {'success': true, 'notifications': jsonDecode(res.body) as List};
      }
      return _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> markNotificationsRead(
      {List<String>? ids}) async {
    try {
      final res = await _req('POST', '/notifications/mark-read', body: {
        if (ids != null) 'ids': ids,
      });
      return res.statusCode == 200 ? {'success': true} : _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> getDelegates() async {
    try {
      final res = await _req('GET', '/delegates');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return {
          'success': true,
          'delegates': data['delegates'] as List<dynamic>,
          'delegatedTo': data['delegatedTo'],
          'currentDelegateName': data['currentDelegateName'],
          'votingPower': data['votingPower'],
        };
      }
      return _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> delegate(String delegateId) async {
    try {
      final res = await _req('POST', '/delegates/$delegateId');
      return res.statusCode == 200 ? {'success': true} : _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> revokeDelegation() async {
    try {
      final res = await _req('POST', '/delegates/revoke');
      return res.statusCode == 200 ? {'success': true} : _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> getOnboardingOptions() async {
    try {
      final res = await _req('GET', '/onboarding/options');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return {
          'success': true,
          'roles': data['roles'] as List<dynamic>,
          'interests': data['interests'] as List<dynamic>,
        };
      }
      return _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> completeOnboarding({
    required String role,
    required List<String> interests,
  }) async {
    try {
      final res = await _req('POST', '/onboarding/complete', body: {
        'role': role,
        'interests': interests,
      });
      return res.statusCode == 200 ? {'success': true} : _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> getProposalCategories() async {
    try {
      final res = await _req('GET', '/proposals/categories');
      if (res.statusCode == 200) {
        return {
          'success': true,
          'categories': (jsonDecode(res.body) as List).cast<String>()
        };
      }
      return _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final res = await _req('GET', '/users/me');
      if (res.statusCode == 200) {
        return {'success': true, 'user': User.fromJson(jsonDecode(res.body))};
      }
      return _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> suspendUser(String id) async {
    try {
      final res = await _req('PUT', '/users/$id/suspend');
      return res.statusCode == 200 ? {'success': true} : _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> reactivateUser(String id) async {
    try {
      final res = await _req('PUT', '/users/$id/reactivate');
      return res.statusCode == 200 ? {'success': true} : _err(res);
    } catch (_) {
      return _netErr();
    }
  }

  Future<Map<String, dynamic>> promoteUser(String id) async {
    try {
      final res = await _req('PUT', '/users/$id/promote');
      return res.statusCode == 200 ? {'success': true} : _err(res);
    } catch (_) {
      return _netErr();
    }
  }
}
