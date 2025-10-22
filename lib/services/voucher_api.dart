import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/voucher_model.dart';
import 'package:topmortarseller/services/api.dart';

class VoucherApi {
  Future<void> list({
    required String idContact,
    required String isClaimed,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(List<VoucherModel>? data) onCompleted,
  }) async {
    List<VoucherModel>? data;
    try {
      final url = Uri.https(baseUrl, 'api/voucher-toko', {
        'id_contact': idContact,
        'is_claimed': isClaimed,
      });
      final response = await http.get(url, headers: headerSetup);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJsonList(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.listData != null) {
            data = apiResponse.listData
                ?.map((e) => VoucherModel.fromJson(e))
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

  Future<void> claim({
    required String idVoucher,
    Function(String e)? onError,
    Function(String e)? onSuccess,
    required Function(VoucherModel? data) onCompleted,
  }) async {
    VoucherModel? data;
    try {
      final url = Uri.https(baseUrl, 'api/voucher-toko/claim');
      final response = await http.post(
        url,
        headers: headerSetup,
        body: json.encode({'id_voucher': idVoucher}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.data != null) {
            data = VoucherModel.fromJson(apiResponse.data!);
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

  Future<List<VoucherModel>> fetchListVoucher({
    required String idContact,
    bool isClaimed = false,
  }) async {
    List<VoucherModel> items = [];
    String messageError = "";

    await list(
      idContact: idContact,
      isClaimed: isClaimed ? "1" : "0",
      onError: (e) => messageError = e,
      onCompleted: (data) {
        items = data ?? [];
      },
    );

    if (messageError.isNotEmpty) {
      throw Exception(messageError);
    }

    return items;
  }
}
