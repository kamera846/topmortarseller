import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/product_model.dart';
import 'package:topmortarseller/services/api.dart';

class ProductApiService {
  Future<List<ProductModel>?> list({
    String? idCity,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(List<ProductModel> data) onCompleted,
  }) async {
    List<ProductModel> data = [];
    try {
      final url = Uri.https(baseUrl, 'api/produk', {'city': idCity ?? ''});
      final response = await http.get(
        url,
        headers: headerSetup,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJsonList(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.listData != null) {
            data = apiResponse.listData!
                .map((item) => ProductModel.fromJson(item))
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
