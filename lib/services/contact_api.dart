import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/services/api.dart';

class ContactApiService {

  // Until now, it is just for debugging only
  Future<List<ContactModel>?> byId({
    required String idContact,
    required String idDistributor,
    required Function(String data) onSuccess,
    required Function(String e) onError,
    required Function() onCompleted,
  }) async {
    List<ContactModel>? data;
    try {
      final url = Uri.https(baseUrlSales, 'contacts.php', {'id': idContact, 'dst': idDistributor});
      final response = await http.get(
        url,
        headers: headerSetup,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJsonList(responseBody);

        if (apiResponse.status == "ok") {
          if (apiResponse.results != null) {
            data = apiResponse.results
                ?.map((item) => ContactModel.fromJson(item))
                .toList();
          }
          onSuccess(apiResponse.msg);
          return data;
        }

        onError(apiResponse.msg);
        return data;
      } else {
        onError('$failedRequestText. Status Code: ${response.statusCode}. Response: ${response.request}');
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
