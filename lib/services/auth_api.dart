import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:topmortarseller/services/api.dart';

class AuthApiService {
  Future<Response> login({
    required String phoneNumber,
    required String password,
  }) async {
    final url = Uri.https(baseUrl, 'api/auth/login');
    final response = await http.post(
      url,
      headers: headerSetup,
      body: json.encode({
        'nomorhp': phoneNumber,
        'pass_contact': password,
      }),
    );

    return response;
  }

  Future<Response> fetchRegister({required String phoneNumber}) async {
    final url = Uri.https(baseUrl, 'api/auth/register');
    final response = await http.post(
      url,
      headers: headerSetup,
      body: json.encode({'nomorhp': phoneNumber}),
    );

    return response;
  }

  Future<Response> requestOtp(
      {required String idContact, required String idDistributor}) async {
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

  Future<Response> verifyOtp(
      {required String idContact, required String otp}) async {
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

  Future<Response> resetPassword(
      {required String idContact, required String password}) async {
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

  Future<void> requestDeleteAccount({
    String? idContact,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    Function()? onCompleted,
  }) async {
    try {
      final url = Uri.https(baseUrl, 'api/contact/delete');
      final response = await http.post(url,
          headers: headerSetup,
          body: jsonEncode({
            'id_contact': idContact ?? '',
          }));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (onSuccess != null) {
            onSuccess(apiResponse.msg);
          }
          return;
        }

        if (onError != null) {
          onError(apiResponse.msg);
        }
        return;
      } else {
        if (onError != null) {
          onError('$failedRequestText. Status Code: ${response.statusCode}');
        }
        return;
      }
    } catch (e) {
      if (onError != null) {
        onError('$failedRequestText. Exception: $e');
      }
      return;
    } finally {
      if (onCompleted != null) {
        onCompleted();
      }
    }
  }
}
