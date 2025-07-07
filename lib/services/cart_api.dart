import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/cart_model.dart';
import 'package:topmortarseller/services/api.dart';

class CartApiService {
  Future<CartModel?> get({
    required String idContact,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(CartModel? data) onCompleted,
  }) async {
    CartModel? data;
    try {
      final params = {'id_contact': idContact};
      final url = Uri.https(baseUrl, 'api/cart', params);
      final response = await http.get(url, headers: headerSetup);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.data != null) {
            data = CartModel.fromJson(apiResponse.data!);
          }
          if (onSuccess != null) {
            onSuccess(apiResponse.msg);
          }
          return data;
        }

        if (onError != null) {
          onError(apiResponse.msg);
        }
        return data;
      } else {
        if (onError != null) {
          onError('$failedRequestText. Status Code: ${response.statusCode}');
        }
        return data;
      }
    } catch (e) {
      if (onError != null) {
        onError('$failedRequestText. Exception: $e');
      }
      return data;
    } finally {
      onCompleted(data);
    }
  }
}
