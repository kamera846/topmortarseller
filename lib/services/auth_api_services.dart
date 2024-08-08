// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:topmortarseller/services/api.dart';

class AuthApiService {
  Future<Response> fetchRegister(String phoneNumber) async {
    final url = Uri.https(baseUrl, 'api/auth/register');
    final response = await http.post(
      url,
      headers: headerSetup,
      body: json.encode({'nomorhp': phoneNumber}),
    );

    return response;
  }
}
