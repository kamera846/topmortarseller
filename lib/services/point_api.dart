import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/services/api.dart';

import '../model/point_model.dart';

class PointApi {
  static Future<int> total({
    required String idContact,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(int point) onCompleted,
  }) async {
    int data = 0;
    try {
      final params = {'id_contact': idContact};
      final url = Uri.https(baseUrl, 'api/point/total', params);
      final response = await http.get(url, headers: headerSetup);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.data != null) {
            data =
                int.tryParse(
                  apiResponse.data?['val_point']?.toString() ?? '',
                ) ??
                0;
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

  static Future<List<PointModel>> history({
    required String idContact,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(List<PointModel> history) onCompleted,
  }) async {
    List<PointModel> data = [];
    try {
      final params = {'id_contact': idContact};
      final url = Uri.https(baseUrl, 'api/point', params);
      final response = await http.get(url, headers: headerSetup);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJsonList(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.listData != null &&
              apiResponse.listData!.isNotEmpty) {
            data =
                apiResponse.listData
                    ?.map((item) => PointModel.fromJson(item))
                    .toList() ??
                [];
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

  Future<PointModel?> request({
    required String idContact,
    required String idMerchandise,
    required String priceMerchandise,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(PointModel? data) onCompleted,
  }) async {
    PointModel? data;
    try {
      final url = Uri.https(baseUrl, 'api/point/redeem');
      final response = await http.post(
        url,
        headers: headerSetup,
        body: json.encode({
          'id_contact': idContact,
          'id_merchandise': idMerchandise,
          'price_merchandise': priceMerchandise,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.data != null) {
            data = PointModel.fromJson(apiResponse.data!);
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
