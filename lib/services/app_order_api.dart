import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/order_model.dart';
import 'package:topmortarseller/services/api.dart';

class AppOrderApi {
  Future<List<OrderModel>?> get({
    required String idContact,
    String statusOrder = 'ALL',
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(List<OrderModel>? data) onCompleted,
  }) async {
    List<OrderModel>? data;
    try {
      final params = {'id_contact': idContact, 'status': statusOrder};
      final url = Uri.https(baseUrl, 'api/apporder', params);
      final response = await http.get(url, headers: headerSetup);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJsonList(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.listData != null) {
            data = apiResponse.listData
                ?.map((e) => OrderModel.fromJson(e))
                .toList();
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

  Future<OrderModel?> detail({
    required String idAppOrder,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(OrderModel? data) onCompleted,
  }) async {
    OrderModel? data;
    try {
      final params = {'id_apporder': idAppOrder};
      final url = Uri.https(baseUrl, 'api/apporder/detail', params);
      final response = await http.get(url, headers: headerSetup);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.data != null) {
            data = OrderModel.fromJson(apiResponse.data!);
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
