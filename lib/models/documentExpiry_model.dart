class DocumentExpiry {
  final String docType;
  final String storagePath;
  final String? expiryDate;
  final bool isExpired;
  final bool hasExpiry;

  DocumentExpiry({
    required this.docType,
    required this.storagePath,
    this.expiryDate,
    required this.isExpired,
    required this.hasExpiry,
  });

  factory DocumentExpiry.fromJson(Map<String, dynamic> json) {
    return DocumentExpiry(
      docType: json['doc_type'] ?? "Unknown Document",
      storagePath: json['storage_path'] ?? "",
      expiryDate: json['expiry_date'],
      isExpired: json['is_expired'] ?? false,
      hasExpiry: json['has_expiry'] ?? false,
    );
  }
}