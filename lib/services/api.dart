const baseUrl = 'dev-seller.topmortarindonesia.com';
const headerSetup = {'Content-Type': 'application/json'};
const failedRequestText = 'Gagal memproses data';

class ApiResponse {
  final int code;
  final String status;
  final String msg;
  final Map<String, dynamic>? data;

  ApiResponse({
    required this.code,
    required this.status,
    required this.msg,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'],
      status: json['status'],
      msg: json['msg'],
      data: json['data'],
    );
  }
}
