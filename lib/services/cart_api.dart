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

  Future<void> insert({
    required String idCart,
    required String idProduct,
    required String qty,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function() onCompleted,
  }) async {
    try {
      final url = Uri.https(baseUrl, 'api/cart/insert');
      final response = await http.post(
        url,
        headers: headerSetup,
        body: json.encode({
          'id_cart': idCart,
          'id_produk': idProduct,
          'qty_cart_detail': qty,
        }),
      );

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
      onCompleted();
    }
  }

  Future<void> delete({
    required String idCartDetail,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function() onCompleted,
  }) async {
    try {
      final url = Uri.https(baseUrl, 'api/cart/delete');
      final response = await http.post(
        url,
        headers: headerSetup,
        body: json.encode({'id_cart_detail': idCartDetail}),
      );

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
      onCompleted();
    }
  }

  Future<void> checkout({
    required String idContact,
    required String idCart,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(bool status) onCompleted,
  }) async {
    bool status = false;
    try {
      final url = Uri.https(baseUrl, 'api/cart/checkout');
      final response = await http.post(
        url,
        headers: headerSetup,
        body: json.encode({'id_contact': idContact, 'id_cart': idCart}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (onSuccess != null) {
            onSuccess(apiResponse.msg);
          }
          status = true;
          return;
        }

        if (onError != null) {
          onError(apiResponse.msg);
        }
        status = false;
        return;
      } else {
        if (onError != null) {
          onError('$failedRequestText. Status Code: ${response.statusCode}');
        }
        status = false;
        return;
      }
    } catch (e) {
      if (onError != null) {
        onError('$failedRequestText. Exception: $e');
      }
      status = false;
      return;
    } finally {
      onCompleted(status);
    }
  }
}
