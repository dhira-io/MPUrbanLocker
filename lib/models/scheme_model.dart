class SchemeResponse {
  final String citizenId;
  final List<SchemeMatch> matches;

  SchemeResponse({required this.citizenId, required this.matches});

  factory SchemeResponse.fromJson(Map<String, dynamic> json) {
    // 1. Get the 'data' map first
    final data = json['data'] as Map<String, dynamic>? ?? {};

    // 2. Extract matches from data
    final matchesList = data['matches'] as List? ?? [];

    return SchemeResponse(
      citizenId: data['citizen_id'] ?? "",
      matches: matchesList.map((i) => SchemeMatch.fromJson(i)).toList(),
    );
  }
}

class SchemeMatch {
  final String schemeName;
  final String summary;
  final String issuingAuthority;
  final String applicationProcess;
  final List<dynamic> benefits;
  final List<dynamic> eligibilityRules;
  final String status;

  SchemeMatch({
    required this.schemeName,
    required this.summary,
    required this.issuingAuthority,
    required this.applicationProcess,
    required this.benefits,
    required this.eligibilityRules,
    required this.status,
  });

  factory SchemeMatch.fromJson(Map<String, dynamic> json) {
    final schemeInfo = json['scheme_info'] ?? {};
    final dsl = schemeInfo['eligibility_rule_dsl'] ?? {};

    return SchemeMatch(
      schemeName: json['scheme_name'] ?? "Unknown Scheme",
      status: json['status'] ?? "UNKNOWN",
      summary: dsl['scheme_summary'] ?? "No summary available.",
      issuingAuthority: dsl['issuing_authority'] ?? "N/A",
      applicationProcess: dsl['application_process'] ?? "N/A",
      benefits: dsl['benefits'] as List? ?? [],
      eligibilityRules: dsl['eligibility_rules'] as List? ?? [],
    );
  }
}