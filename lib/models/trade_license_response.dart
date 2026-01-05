/*
class TradeLicenseResponse {
  final bool success;
  final PdfData data;

  TradeLicenseResponse({required this.success, required this.data});

  factory TradeLicenseResponse.fromJson(Map<String, dynamic> json) {
    return TradeLicenseResponse(
      success: json['success'] ?? false,
      data: PdfData.fromJson(json['data']),
    );
  }
}

class PdfData {
  final String pdf;
  final String mimeType;
  final int size;

  PdfData({required this.pdf, required this.mimeType, required this.size});

  factory PdfData.fromJson(Map<String, dynamic> json) {
    return PdfData(
      pdf: json['pdf'] ?? '',
      mimeType: json['mimeType'] ?? '',
      size: json['size'] ?? 0,
    );
  }
}*/
