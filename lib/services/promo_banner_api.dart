import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/promo_banner_model.dart';
import 'package:topmortarseller/services/api.dart';

class PromoBannerApi {
  Future<List<PromoBannerModel>?> get({
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(List<PromoBannerModel>? data) onCompleted,
  }) async {
    List<PromoBannerModel>? data;
    try {
      final url = Uri.https(baseUrl, 'api/promo');
      final response = await http.get(url, headers: headerSetup);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJsonList(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.listData != null) {
            data = apiResponse.listData
                ?.map((e) => PromoBannerModel.fromJson(e))
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

  Future<PromoBannerModel?> detail({
    required String idPromo,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(PromoBannerModel? data) onCompleted,
  }) async {
    PromoBannerModel? data;
    try {
      final url = Uri.https(baseUrl, 'api/promo');
      final response = await http.get(url, headers: headerSetup);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.data != null) {
            data = PromoBannerModel.fromJson(apiResponse.data!);
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
