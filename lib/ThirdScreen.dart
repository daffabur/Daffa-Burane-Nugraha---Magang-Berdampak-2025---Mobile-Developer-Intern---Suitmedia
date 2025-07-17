import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suitmediatest/models/user.dart'; // Pastikan path ini benar sesuai struktur proyek Anda
import 'package:suitmediatest/services/api_service.dart'; // Pastikan path ini benar
import 'package:suitmediatest/provider/user_provider.dart'; // Pastikan path ini benar

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
  bool _hasMore =
      true; // Menyatakan apakah masih ada data di halaman berikutnya
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Panggil pertama kali untuk memuat data awal
    _scrollController.addListener(
      _onScroll,
    ); // Tambahkan listener untuk memantau scroll
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Sangat penting untuk dispose controller
    super.dispose();
  }

  Future<void> _fetchUsers({bool isRefresh = false}) async {
    // Hindari fetching jika sudah ada proses loading atau jika tidak ada data lagi DAN bukan operasi refresh
    if (_isLoading || (!_hasMore && !isRefresh)) {
      print(
        'DEBUG: Aborting fetch. isLoading: $_isLoading, hasMore: $_hasMore, isRefresh: $isRefresh',
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set status loading menjadi true
      if (isRefresh) {
        _users.clear(); // Hapus data lama saat refresh
        _currentPage = 1; // Reset halaman ke 1 saat refresh
        _hasMore = true; // Asumsikan ada data lagi saat refresh
      }
    });

    try {
      print('DEBUG: Trying to fetch users from page $_currentPage...');
      final newUsers = await _apiService.getUsers(
        page: _currentPage,
        perPage: 12,
      ); // Pastikan perPage 12 di sini
      print('DEBUG: Successfully fetched ${newUsers.length} users.');

      setState(() {
        _users.addAll(newUsers); // Tambahkan user baru ke daftar
        _currentPage++; // Lanjutkan ke halaman berikutnya untuk fetch selanjutnya
        _hasMore =
            newUsers
                .isNotEmpty; // Jika daftar user baru kosong, berarti tidak ada halaman lagi
      });
    } catch (e) {
      print('DEBUG ERROR: Failed to fetch users: $e'); // Log error yang terjadi
      // Tampilkan SnackBar dengan pesan error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() {
        _hasMore = false; // Set hasMore menjadi false jika terjadi error
      });
    } finally {
      setState(() {
        _isLoading = false; // Selesai loading
      });
    }
  }

  void _onScroll() {
    // Cek apakah user sudah mencapai bagian paling bawah dari scroll view
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      print('DEBUG: Scrolled to bottom, fetching next page...');
      _fetchUsers(); // Panggil fungsi untuk memuat halaman berikutnya
    }
  }

  Future<void> _onRefresh() async {
    print('DEBUG: Pulling to refresh...');
    await _fetchUsers(
      isRefresh: true,
    ); // Panggil fetch dengan parameter isRefresh true
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Agar body meluas di belakang AppBar
      appBar: AppBar(
        title: const Text(
          'Third Screen',
          style: TextStyle(color: Colors.black), // Warna teks judul
        ),
        centerTitle: true, // Posisikan judul di tengah
        backgroundColor: Colors.transparent, // Jadikan AppBar transparan
        elevation: 0, // Hapus shadow AppBar
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ), // Warna ikon
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        // Pembungkus body dengan container
        color: Colors.white.withOpacity(
          0.8,
        ), // <--- BARU: Background putih transparan
        child:
            _users.isEmpty && !_isLoading && !_hasMore
                ? const Center(
                  child: Text(
                    'No users found. Pull to refresh or check your internet connection.',
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _onRefresh, // Mengaktifkan pull-to-refresh
                  child: ListView.builder(
                    controller:
                        _scrollController, // Mengaitkan ScrollController
                    itemCount:
                        _users.length +
                        (_isLoading
                            ? 1
                            : 0), // Hitung item + 1 untuk loading indicator
                    itemBuilder: (context, index) {
                      // Tampilkan CircularProgressIndicator di bagian paling bawah daftar jika sedang loading
                      if (index == _users.length && _isLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      // Tampilkan item user normal
                      final user = _users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 2, // Memberikan sedikit elevasi pada card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ), // Sudut membulat
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30, // Ukuran avatar
                            backgroundImage: NetworkImage(user.avatar),
                            backgroundColor:
                                Colors.grey[200], // Placeholder warna
                            onBackgroundImageError: (exception, stackTrace) {
                              // Handle error loading image
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
                            // Update nama user yang dipilih ke provider
                            Provider.of<UserProvider>(
                              context,
                              listen: false,
                            ).setSelectedUserName(
                              '${user.firstName} ${user.lastName}',
                            );
                            // Kembali ke Second Screen
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
