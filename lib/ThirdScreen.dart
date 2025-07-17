import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suitmediatest/models/user.dart';
import 'package:suitmediatest/services/api_service.dart';
import 'package:suitmediatest/provider/user_provider.dart';

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  final ApiService _apiService = ApiService();
  final List<User> _users = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers({bool isRefresh = false}) async {
    if (_isLoading || (!_hasMore && !isRefresh)) {
      print(
        'DEBUG: Aborting fetch. isLoading: $_isLoading, hasMore: $_hasMore, isRefresh: $isRefresh',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _users.clear();
        _currentPage = 1;
        _hasMore = true;
      }
    });

    try {
      print('DEBUG: Trying to fetch users from page $_currentPage...');
      final newUsers = await _apiService.getUsers(
        page: _currentPage,
        perPage: 12,
      );
      print('DEBUG: Successfully fetched ${newUsers.length} users.');

      setState(() {
        _users.addAll(newUsers);
        _currentPage++;
        _hasMore = newUsers.isNotEmpty;
      });
    } catch (e) {
      print('DEBUG ERROR: Failed to fetch users: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() {
        _hasMore = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      print('DEBUG: Scrolled to bottom, fetching next page...');
      _fetchUsers();
    }
  }

  Future<void> _onRefresh() async {
    print('DEBUG: Pulling to refresh...');
    await _fetchUsers(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Third Screen',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white.withOpacity(0.8),
        child:
            _users.isEmpty && !_isLoading && !_hasMore
                ? const Center(
                  child: Text(
                    'No users found. Pull to refresh or check your internet connection.',
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _users.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _users.length && _isLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final user = _users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(user.avatar),
                            backgroundColor: Colors.grey[200],
                            onBackgroundImageError: (exception, stackTrace) {
                              print(
                                'Error loading image for ${user.firstName}: $exception',
                              );
                            },
                          ),
                          title: Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            user.email,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          onTap: () {
                            Provider.of<UserProvider>(
                              context,
                              listen: false,
                            ).setSelectedUserName(
                              '${user.firstName} ${user.lastName}',
                            );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
