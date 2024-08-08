// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:topmortarseller/services/api.dart';

class AuthApiService {
  Future<Response> fetchRegister({String? phoneNumber}) async {
    final url = Uri.https(baseUrl, 'api/auth/register');
    final response = await http.post(
      url,
      headers: headerSetup,
      body: json.encode({'nomorhp': phoneNumber}),
    );

    return response;
  }

  Future<Response> requestOtp(
      {String? idContact, String? idDistributor}) async {
    final url = Uri.https(baseUrl, 'api/request-otp');
    final response = await http.post(
      url,
      headers: headerSetup,
      body: json.encode({
        'id_contact': idContact,
        'id_distributor': idDistributor,
      }),
    );

    return response;
  }

  Future<Response> verifyOtp({String? idContact, String? otp}) async {
    final url = Uri.https(baseUrl, 'api/verify-otp');
    final response = await http.post(
      url,
      headers: headerSetup,
      body: json.encode({
        'id_contact': idContact,
        'otp': otp,
      }),
    );

    return response;
  }

  Future<Response> resetPassword({String? idContact, String? password}) async {
    final url = Uri.https(baseUrl, 'api/auth/reset');
    final response = await http.post(
      url,
      headers: headerSetup,
      body: json.encode({
        'id_contact': idContact,
        'pass_contact': password,
      }),
    );

    return response;
  }
}
