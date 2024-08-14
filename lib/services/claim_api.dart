import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/claim_cashback_model.dart';
import 'package:topmortarseller/services/api.dart';

class ClaimCashbackServices {
  Future<ClaimCashbackModel?> newBank({
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
}
