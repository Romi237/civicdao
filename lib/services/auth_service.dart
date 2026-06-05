import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _i = AuthService._();
  factory AuthService() => _i;
  AuthService._();

  User?   _user;
  String? _token;
  String? _refreshToken;

  User?   get currentUser => _user;
  bool    get isLoggedIn   => _user != null && _token != null;
  bool    get isAdmin      => _user?.isAdmin ?? false;
  String? get token        => _token;

  String get _base =>
      dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:3000/api');

  Map<String, String> get authHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ── Restore session on app start ─────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final tok      = prefs.getString('token');
    final refresh  = prefs.getString('refreshToken');
    if (userJson != null && tok != null) {
      _user         = User.fromJson(jsonDecode(userJson));
      _token        = tok;
      _refreshToken = refresh;
      notifyListeners();
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register(
      String email, String password, String name) async {
    try {
      final res = await http
          .post(Uri.parse('$_base/register'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(
                  {'email': email, 'password': password, 'name': name}))
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body);
      if (res.statusCode == 201 || res.statusCode == 200) {
        await _save(data);
        return {'success': true};
      }
      return {'success': false, 'error': data['error'] ?? 'Registration failed.'};
    } catch (_) {
      return {'success': false, 'error': 'Cannot reach server.'};
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http
          .post(Uri.parse('$_base/login'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': email, 'password': password}))
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        await _save(data);
        return {'success': true};
      }
      return {'success': false, 'error': data['error'] ?? 'Login failed.'};
    } catch (_) {
      return {'success': false, 'error': 'Cannot reach server.'};
    }
  }

  // ── Refresh token ─────────────────────────────────────────────────────────
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;
    try {
      final res = await http
          .post(Uri.parse('$_base/refresh'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'refreshToken': _refreshToken}))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token        = data['token'];
        _refreshToken = data['refreshToken'];
        final prefs   = await SharedPreferences.getInstance();
        await prefs.setString('token',        _token!);
        await prefs.setString('refreshToken', _refreshToken!);
        notifyListeners();
        return true;
      }
      await logout();
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      if (_token != null) {
        await http
            .post(Uri.parse('$_base/logout'),
                headers: authHeaders,
                body: jsonEncode({'refreshToken': _refreshToken}))
            .timeout(const Duration(seconds: 10));
      }
    } catch (_) {}
    _user = null; _token = null; _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    notifyListeners();
  }

  // ── Vote tracking ─────────────────────────────────────────────────────────
  bool canVoteOn(String id) => _user?.canVoteOn(id) ?? false;

  void addVotedProposal(String id) {
    if (_user != null) {
      _user = _user!.copyWithVote(id);
      _persist();
      notifyListeners();
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────
  Future<void> _save(Map<String, dynamic> data) async {
    _token        = data['token'];
    _refreshToken = data['refreshToken'];
    _user         = User.fromJson(data['user']);
    final prefs   = await SharedPreferences.getInstance();
    await prefs.setString('user',  jsonEncode(_user!.toJson()));
    await prefs.setString('token', _token!);
    if (_refreshToken != null) {
      await prefs.setString('refreshToken', _refreshToken!);
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_user!.toJson()));
  }
}
