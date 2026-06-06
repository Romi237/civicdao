import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/proposal.dart';
import '../services/api_service.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<User> _users = [];
  List<Proposal> _proposals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final usersResult = await api.getUsers();
      final proposalsResult = await api.getProposals();
      setState(() {
        _users =
            usersResult['success'] ? usersResult['users'] as List<User> : [];
        _proposals = proposalsResult['success']
            ? proposalsResult['proposals'] as List<Proposal>
            : [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load data: $e'),
              backgroundColor: AppColors.red),
        );
      }
    }
  }

  Future<void> _updateProposalStatus(Proposal p, ProposalStatus status) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      await api.updateProposalStatus(p.id, status.apiValue);
      setState(() {
        final index = _proposals.indexWhere((el) => el.id == p.id);
        if (index != -1) {
          _proposals[index] = _proposals[index].copyWith(status: status);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Proposal status updated'),
              backgroundColor: AppColors.purple),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  Future<void> _suspendUser(User u) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      await api.suspendUser(u.id);
      setState(() {
        final index = _users.indexWhere((el) => el.id == u.id);
        if (index != -1) {
          _users[index] = _users[index].copyWith(isActive: false);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User suspended'),
              backgroundColor: AppColors.purple),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  Future<void> _reactivateUser(User u) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      await api.reactivateUser(u.id);
      setState(() {
        final index = _users.indexWhere((el) => el.id == u.id);
        if (index != -1) {
          _users[index] = _users[index].copyWith(isActive: true);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User reactivated'),
              backgroundColor: AppColors.purple),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  Future<void> _promoteUser(User u) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      await api.promoteUser(u.id);
      setState(() {
        final index = _users.indexWhere((el) => el.id == u.id);
        if (index != -1) {
          _users[index] = _users[index].copyWith(role: 'admin');
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User promoted to admin'),
              backgroundColor: AppColors.purple),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SectionHeader(title: 'Users (${_users.length})'),
                  const SizedBox(height: 12),
                  ..._users.map((user) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(user.name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                        Text(user.email,
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 14)),
                                        Row(
                                          children: [
                                            StatusBadge(user.role),
                                            const SizedBox(width: 8),
                                            StatusBadge(user.isActive
                                                ? 'Active'
                                                : 'Suspended'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (user.isActive && user.role == 'member')
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: ElevatedButton(
                                        onPressed: () => _promoteUser(user),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.purple,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Promote'),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (user.isActive)
                                    OutlinedButton(
                                      onPressed: () => _suspendUser(user),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: AppColors.red),
                                        foregroundColor: AppColors.red,
                                      ),
                                      child: const Text('Suspend'),
                                    ),
                                  if (!user.isActive)
                                    ElevatedButton(
                                      onPressed: () => _reactivateUser(user),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.purple,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Reactivate'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),
                  SectionHeader(title: 'Proposals (${_proposals.length})'),
                  const SizedBox(height: 12),
                  ..._proposals.map((proposal) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(proposal.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  StatusBadge(proposal.status.label),
                                  Text('\$${proposal.requestedBudget}',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(proposal.description,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (proposal.status == ProposalStatus.pending)
                                    ElevatedButton(
                                      onPressed: () => _updateProposalStatus(
                                          proposal, ProposalStatus.voting),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.purple,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Start Voting'),
                                    ),
                                  if (proposal.status ==
                                      ProposalStatus.voting) ...[
                                    ElevatedButton(
                                      onPressed: () => _updateProposalStatus(
                                          proposal, ProposalStatus.accepted),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.purple,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Accept'),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => _updateProposalStatus(
                                          proposal, ProposalStatus.rejected),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: AppColors.red),
                                        foregroundColor: AppColors.red,
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}
