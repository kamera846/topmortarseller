import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/customer_bank_model.dart';
import 'package:topmortarseller/services/api.dart';

class CustomerBankApiService {
  Future<List<CustomerBankModel>?> banks({
    required String idContact,
    required Function(String e) onSuccess,
    required Function(String e) onError,
    required Function() onCompleted,
  }) async {
    List<CustomerBankModel>? data;
    try {
      final url = Uri.https(baseUrl, 'api/rekeningtoko/contact/$idContact');
      final response = await http.get(
        url,
        headers: headerSetup,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJsonList(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.listData != null) {
            data = apiResponse.listData
                ?.map((item) => CustomerBankModel.fromJson(item))
                .toList();
          }
          onSuccess(apiResponse.msg);
          return data;
        }

        onError(apiResponse.msg);
        return data;
      } else {
        onError('$failedRequestText. Status Code: ${response.statusCode}');
        return data;
      }
    } catch (e) {
      onError('$failedRequestText. Exception: $e');
      return data;
    } finally {
      onCompleted();
    }
  }

  Future<CustomerBankModel?> newBank({
    required String idContact,
    required String idBank,
    required String nameRek,
    required String noRek,
    required Function(String e) onSuccess,
    required Function(String e) onError,
    required Function() onCompleted,
  }) async {
    CustomerBankModel? item;
    try {
      final url = Uri.https(baseUrl, 'api/rekeningtoko');
      final response = await http.post(
        url,
        headers: headerSetup,
        body: json.encode(
          {
            'id_contact': idContact,
            'id_bank': idBank,
            'to_name': nameRek,
            'to_account': noRek,
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.data != null) {
            item = CustomerBankModel.fromJson(apiResponse.data!);
          }
          onSuccess(apiResponse.msg);
          return item;
        }

        onError(apiResponse.msg);
        return item;
      } else {
        onError('$failedRequestText. Status Code: ${response.statusCode}');
        return item;
      }
    } catch (e) {
      onError('$failedRequestText. Exception: $e');
      return item;
    } finally {
      onCompleted();
    }
  }
}
