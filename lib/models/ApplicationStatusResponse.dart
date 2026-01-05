//dummy model

class ApplicationStatusResponse {
  final String applicationId;
  final String status;
  final String currentStep;
  final String nextStep;
  final String statusMessage;
  final DateTime lastUpdated;

  ApplicationStatusResponse({
    required this.applicationId,
    required this.status,
    required this.currentStep,
    required this.nextStep,
    required this.statusMessage,
    required this.lastUpdated,
  });

  factory ApplicationStatusResponse.fromJson(Map<String, dynamic> json) {
    return ApplicationStatusResponse(
      applicationId: json["applicationId"] ?? "",
      status: json["status"] ?? "",
      currentStep: json["currentStep"] ?? "",
      nextStep: json["nextStep"] ?? "",
      statusMessage: json["statusMessage"] ?? "",
      lastUpdated: DateTime.parse(json["lastUpdated"] ?? DateTime.now().toIso8601String()),
    );
  }
}
