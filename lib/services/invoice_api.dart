import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/invoice_model.dart';
import 'package:topmortarseller/services/api.dart';

class InvoiceApi {
  Future<List<InvoiceModel>?> get({
    required String idContact,
    String statusInvoice = 'ALL',
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(List<InvoiceModel>? data) onCompleted,
  }) async {
    List<InvoiceModel>? data;
    try {
      final params = {'id_contact': idContact, 'status': statusInvoice};
      final url = Uri.https(baseUrl, 'api/invoice', params);
      final response = await http.get(url, headers: headerSetup);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJsonList(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.listData != null) {
            data = apiResponse.listData
                ?.map((e) => InvoiceModel.fromJson(e))
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
}
