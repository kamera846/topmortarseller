import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/merchandise_model.dart';
import 'package:topmortarseller/services/api.dart';

class MerchandiseApi {
  Future<void> list({
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(List<MerchandiseModel>? data) onCompleted,
  }) async {
    List<MerchandiseModel>? data;
    try {
      final url = Uri.https(baseUrl, 'api/merchandise');
      final response = await http.get(url, headers: headerSetup);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJsonList(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.listData != null) {
            data = apiResponse.listData
                ?.map((e) => MerchandiseModel.fromJson(e))
                .toList();
          }
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
      onCompleted(data);
    }
  }

  Future<void> detail({
    required String id,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(MerchandiseModel? data) onCompleted,
  }) async {
    MerchandiseModel? data;
    try {
      final url = Uri.https(baseUrl, 'api/merchandise/$id');
      final response = await http.get(url, headers: headerSetup);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.data != null) {
            data = MerchandiseModel.fromJson(apiResponse.data!);
          }
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
      onCompleted(data);
    }
  }
}
