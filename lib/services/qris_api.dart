import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/qris_model.dart';
import 'package:topmortarseller/services/api.dart';

class QrisApi {
  Future<QrisModel?> check({
    required String idInvoice,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(QrisModel? data) onCompleted,
  }) async {
    QrisModel? data;
    try {
      final url = Uri.https(baseUrl, 'api/qris/check');
      final response = await http.post(
        url,
        headers: headerSetup,
        body: json.encode({'id_invoice': idInvoice}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.data != null) {
            data = QrisModel.fromJson(apiResponse.data!);
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

  Future<QrisModel?> request({
    required String idInvoice,
    required String amountPayment,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(QrisModel? data) onCompleted,
  }) async {
    QrisModel? data;
    try {
      final url = Uri.https(baseUrl, 'api/qris/request');
      final response = await http.post(
        url,
        headers: headerSetup,
        body: json.encode({
          'id_invoice': idInvoice,
          'amount_payment': amountPayment,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200 || apiResponse.code == 400) {
          if (apiResponse.data != null) {
            data = QrisModel.fromJson(apiResponse.data!);
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

  Future<QrisModel?> payment({
    required String idQrisPayment,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(QrisModel? data) onCompleted,
  }) async {
    QrisModel? data;
    try {
      final url = Uri.https(baseUrl, 'api/qris/payment');
      final response = await http.post(
        url,
        headers: headerSetup,
        body: json.encode({'id_qris_payment': idQrisPayment}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200 || apiResponse.code == 401) {
          if (apiResponse.data != null) {
            data = QrisModel.fromJson(apiResponse.data!);
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
