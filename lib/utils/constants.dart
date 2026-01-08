class AppConstants {
  // API Configuration
  static const String baseUrl =  'https://0w5c7rsr-3001.inc1.devtunnels.ms';//
  //'https://dev.uatenagarpalika.in:5443'; //'https://mpurbanlocker.in'; // ;
    // 'https://fqstnlh6-3001.inc1.devtunnels.ms'; // Android emulator localhost

  // API Endpoints
  static const String sessionEndpoint = '/api/digilocker/session';
  static const String callbackEndpoint = '/api/digilocker/callback';
  static const String sessionStatusEndpoint = '/api/digilocker/session';
  static const String callbackCompleteEndpoint = '/api/digilocker/callback_complete';

  static const String demoSendOTPEndpoint = '/api/auth/demo/send-otp'; //'/api/digilocker/demo/send-otp';
  static const String demoVerifyOTPEndpoint = '/api/auth/demo/verify-otp';//'/api/auth/demo/verify-otp';

  //services endpoint
  static const String tradeLicenseEndpoint = '/api/enagarpalika/trade-license';
  static const String fireNocEndpoint = '/api/enagarpalika/fire-noc';
  static const String fireSafetyEndpoint = '/api/enagarpalika/fire-safety-certificate';
  static const String waterCertificateEndpoint = '/api/enagarpalika/water-certificate';
  static const String waterNocEndpoint = '/api/enagarpalika/water-noc';
  static const String propertyNocEndpoint = '/api/enagarpalika/property-certificate';
  static const String newpropertyEndpoint = '/api/enagarpalika/new-property-application';
  static const String marriageCertificateEndpoint = '/api/enagarpalika/marriage-certificate';
  static const String sewerageConnectionEndpoint = '/api/enagarpalika/sewerage-connection';
  static const String treeCuttingTransitEndpoint = '/api/enagarpalika/tree-cutting-transit';
  static const String propertyTaxReceiptEndpoint = '/api/enagarpalika/property-tax-receipt';
  static const String hoardingLicenseEndpoint = '/api/enagarpalika/hoarding-license';
  static const String propertyMutationEndpoint = '/api/enagarpalika/property-mutation';
  static const String waterTaxReceiptEndpoint = '/api/enagarpalika/water-tax-receipt';

  //scheme
  static const String schemeMatchesEndpoint = '/api/users/me/scheme-matches?min_percentage=0';
  static const String documentsExpiryEndpoint = '/api/users/me/documents-expiry';
  static const String documentsFetchByDocIDEndpoint = '/api/users/me/documents/fetch';




  // User endpoints
  static String userProfileEndpoint(String userId) =>
      '/api/users/$userId/profile';
  static String userDocumentsEndpoint(String userId) =>
      '/api/users/$userId/documents';
  static String documentFileEndpoint(String userId, String docId) =>
      '/api/users/$userId/documents/$docId/file';



  // Deep Link Scheme
  static const String deepLinkScheme = 'mplocker';
  static const String callbackPath = 'callback';
  static const String deepLinkCallback = '$deepLinkScheme://$callbackPath';

  // Polling Configuration
  static const int sessionPollingIntervalMs = 1000; // 1 second
  static const int maxPollingAttempts = 120; // 2 minutes total

  // Storage Keys
  static const String tokenKey = 'token';
  static const String userIdKey = 'userId';
  static const String userKey = 'user';
  static const String pkceStateKey = 'pkce_state';
  static const String pkceVerifierKey = 'pkce_verifier';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;

  // Document Categories
  static const List<String> documentCategories = [
    'All',
    'Identity',
    'Education',
    'Employment',
    'Financial',
    'Health',
    'Utilities',
    'Vehicle',
    'Property',
    'Other',
  ];

  static const appSlides = [
    {
      "title": "Your Secure Digital Locker",
      "subtitle": "Store, manage, and access all your documents in one place.",
      "image": "assets/slider1.png",
    },
    {
      "title": "Verified and Trusted",
      "subtitle": "Official verification backed by Government of MP.",
      "image": "assets/slider2.png",
    },
    {
      "title": "Share with Ease",
      "subtitle": "Securely share documents with anyone anytime.",
      "image": "assets/slider3.png",
    },
  ];

}
