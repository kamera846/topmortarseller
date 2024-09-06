import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/claim_cashback_model.dart';
import 'package:topmortarseller/model/claimed_model.dart';
import 'package:topmortarseller/services/api.dart';

class ClaimCashbackServices {
  Future<ClaimCashbackModel?> claim({
    required String idContact,
    required String idMd5,
    required Function(String e) onSuccess,
    required Function(String e) onError,
    required Function() onCompleted,
  }) async {
    ClaimCashbackModel? data;
    try {
      final url = Uri.https(baseUrl, 'api/voucher/claim');
      final response = await http.post(
        url,
        headers: headerSetup,
        body: json.encode(
          {
            'id_contact': idContact,
            'id_md5': idMd5,
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.data != null) {
            data = ClaimCashbackModel.fromJson(apiResponse.data!);
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

  Future<List<ClaimedModel>?> claimed({
    required String idContact,
    required Function(String e) onSuccess,
    required Function(String e) onError,
    required Function() onCompleted,
  }) async {
    List<ClaimedModel>? data;
    try {
      final url = Uri.https(baseUrl, 'api/voucher/claimed/$idContact');
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
                ?.map((item) => ClaimedModel.fromJson(item))
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
}
