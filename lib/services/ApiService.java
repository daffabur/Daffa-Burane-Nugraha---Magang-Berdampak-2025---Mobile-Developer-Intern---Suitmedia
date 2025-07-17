import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:suitmediatest/models/user.dart'; // Sesuaikan path ini jika perlu

class ApiService {
  static const String _baseUrl = 'https://reqres.in/api/users';

  // Ubah perPage di sini menjadi 12 atau lebih untuk memastikan ada cukup data untuk di-scroll
  Future<List<User>> getUsers({int page = 1, int perPage = 12}) async { // <--- PASTIKAN perPage = 12
    try {
      final uri = Uri.parse('$_baseUrl?page=$page&per_page=$perPage');
      print('DEBUG API: Fetching from URL: $uri'); // Untuk debugging, cek URL yang dikirim
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> userList = data['data'];
        return userList.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }
}