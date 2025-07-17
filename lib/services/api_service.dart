import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:suitmediatest/models/user.dart';

class ApiService {
  static const String _baseUrl = 'https://reqres.in/api';

  Future<List<User>> getUsers({int page = 1, int perPage = 10}) async {
    try {
      final uri = Uri.parse(
        'https://reqres.in/api/users?page=$page&per_page=$perPage',
      );
      final response = await http
          .get(
            uri,
            headers: {
              'x-api-key': 'reqres-free-v1', 
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('data') && data['data'] is List) {
          final List<dynamic> userList = data['data'];
          return userList
              .map((json) => User.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Invalid response structure');
        }
      } else {
        throw HttpException('Failed to load users: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on HttpException catch (e) {
      throw Exception('HttpException: ${e.message}');
    } on FormatException {
      throw Exception('Bad response format');
    } on TimeoutException {
      throw Exception('Request timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
