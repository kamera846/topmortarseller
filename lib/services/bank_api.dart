import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/bank_model.dart';
import 'package:topmortarseller/services/api.dart';

class BankApiService {
  Future<List<BankModel>?> banks(
      {required Function(String e) onError,
      required Function() onCompleted}) async {
    List<BankModel>? items = [];
    try {
      final url = Uri.https(baseUrl, 'api/bank');
      final response = await http.get(
        url,
        headers: headerSetup,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJsonList(responseBody);

        if (apiResponse.code == 200) {
          items = apiResponse.listData
              ?.map((item) => BankModel.fromJson(item))
              .toList();
          return items;
        }

        onError(apiResponse.msg);
        return items;
      } else {
        onError('$failedRequestText. Status Code: ${response.statusCode}');
        return items;
      }
    } catch (e) {
      onError('$failedRequestText. Exception: $e');
      return items;
    } finally {
      onCompleted;
    }
  }
}
