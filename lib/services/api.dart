// const baseUrl = 'seller.topmortarindonesia.com';
// const baseUrlSales = 'saleswa.topmortarindonesia.com';
const baseUrl = 'dev-seller.topmortarindonesia.com';
const baseUrlSales = 'dev-saleswa.topmortarindonesia.com';

const headerSetup = {'Content-Type': 'application/json'};
const failedRequestText = 'Gagal memproses data';

class ApiResponse {
  final int code;
  final String status;
  final String msg;
  final Map<String, dynamic>? data;
  final List<dynamic>? listData;
  final List<dynamic>? results;
  final String? mediaLink;
  final String? quota;

  ApiResponse({
    required this.code,
    required this.status,
    required this.msg,
    this.data,
    this.listData,
    this.results,
    this.mediaLink,
    this.quota,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'] ?? 0,
      status: json['status'] ?? '',
      msg: json['msg'] ?? '',
      data: json['data'],
      mediaLink: json['media_link'],
      quota: json['quota'],
    );
  }

  factory ApiResponse.fromJsonList(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'] ?? 0,
      status: json['status'] ?? '',
      msg: json['msg'] ?? '',
      listData: json['data'],
      results: json['results'],
      mediaLink: json['media_link'],
      quota: json['quota'],
    );
  }
}
