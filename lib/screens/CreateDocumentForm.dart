import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/common_appbar.dart';
import '../models/doc_service_config.dart';
import '../services/api_service.dart';
import '../services/config_service.dart';
import '../utils/constants.dart';
import 'DocumentPreview.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateDocumentForm extends StatefulWidget {
  final String docType;

  const CreateDocumentForm({super.key, required this.docType});

  @override
  _CreateDocumentFormState createState() => _CreateDocumentFormState();
}

class _CreateDocumentFormState extends State<CreateDocumentForm> {
  final _formKey = GlobalKey<FormState>();
  bool consentGiven = false;
  bool isLoading = false;

  DocServiceConfig? serviceConfig;
  final Map<String, TextEditingController> controllers = {};
  final Map<String, TextEditingController> fromYearControllers = {};
  final Map<String, TextEditingController> toYearControllers = {};
  final Map<String, String?> yearErrors = {};


  @override
  void initState() {
    super.initState();

    // Load the config for this service
    serviceConfig = ConfigService.docServices.firstWhere(
          (c) => c.displayName.toLowerCase() == widget.docType.toLowerCase(),
      orElse: () => throw Exception("Service not found for ${widget.docType}"),
    );

    // Initialize controllers per field
    for (final field in serviceConfig!.fields) {
      controllers[field.key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final ctrl in controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Flexible(
                    child: Text(
                      widget.docType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // RichText(
                              //   text: TextSpan(
                              //     children: [
                              //       TextSpan(
                              //         text: "${widget.docType} Number",
                              //         style: const TextStyle(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w500,
                              //           color: Colors.black,
                              //         ),
                              //       ),
                              //       TextSpan(
                              //         text: " *",
                              //         style: const TextStyle(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w400,
                              //           color: Colors.red,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              //
                              // const SizedBox(height: 16),
                              // Dynamic fields from JSON
                              buildFormFields(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: consentGiven,
                                onChanged: (val) =>
                                    setState(() => consentGiven = val ?? false),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  "I hereby give consent to fetch my ${widget.docType} details from concerned authority, Madhya Pradesh and store it securely in my MP Urban Locker for future use.",
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              SizedBox(width: 8),
                              //Image.asset('assets/speaker.png'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (consentGiven && !isLoading) ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "View Document",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: customEndDrawer(context),
    );
  }
  void _validateAndUpdateAssessmentYear(String key) {
    final fromText = fromYearControllers[key]?.text;
    final toText = toYearControllers[key]?.text;

    setState(() {
      yearErrors[key] = null;

      if (fromText == null || fromText.isEmpty) {
        yearErrors[key] = "From Year is required";
        controllers[key]?.clear();
        return;
      }

      if (toText == null || toText.isEmpty) {
        yearErrors[key] = "To Year is required";
        controllers[key]?.clear();
        return;
      }

      final fromYear = int.parse(fromText);
      final toYear = int.parse(toText);

      if (toYear <= fromYear) {
        yearErrors[key] = "To Year must be greater than From Year";
        controllers[key]?.clear();
        return;
      }

      // if (toYear != fromYear + 1) {
      //   yearErrors[key] =
      //   "Assessment year must be consecutive (e.g. 2025-26)";
      //   controllers[key]?.clear();
      //   return;
      // }

      // ✅ VALID → SAVE FORMAT
      final toShort = toYear.toString().substring(2);
      controllers[key]!.text = "$fromYear-$toShort";
    });
  }


  Widget _yearBox({
    required String label,
    required TextEditingController controller,
    required String fieldKey,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onTap: () async {
        FocusScope.of(context).unfocus();

        final currentYear = DateTime.now().year;

        final selectedYear = await showDialog<int>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Select Year"),
              content: SizedBox(
                width: double.maxFinite,
                height: 300, // 👈 REQUIRED
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 50,
                  itemBuilder: (_, index) {
                    final year = DateTime.now().year - index;
                    return ListTile(
                      title: Text(year.toString()),
                      onTap: () => Navigator.pop(context, year),
                    );
                  },
                ),
              ),
            );
          },
        );


        if (selectedYear != null) {
          controller.text = selectedYear.toString();
          _validateAndUpdateAssessmentYear(fieldKey);
        }
      },
    );
  }

  Widget _buildYearPicker(FieldConfig field) {
    fromYearControllers.putIfAbsent(
        field.key, () => TextEditingController());
    toYearControllers.putIfAbsent(
        field.key, () => TextEditingController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _yearBox(
                label: "From Year",
                controller: fromYearControllers[field.key]!,
                fieldKey: field.key,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _yearBox(
                label: "To Year",
                controller: toYearControllers[field.key]!,
                fieldKey: field.key,
              ),
            ),
          ],
        ),

        if (yearErrors[field.key] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              yearErrors[field.key]!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }



  Widget _buildDatePicker(FieldConfig field) {
    return TextFormField(
      controller: controllers[field.key],
      readOnly: true,
      decoration: _inputDecoration(field),
      onTap: () async {
        FocusScope.of(context).unfocus();

        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          controllers[field.key]!.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
        }
      },
      validator: (val) {
        if (field.required && (val == null || val.isEmpty)) {
          return "Required";
        }
        return null;
      },
    );
  }
  InputDecoration _inputDecoration(FieldConfig field) {
    return InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelText: field.label,
      hintText: field.hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildTextInput(FieldConfig field) {
    return TextFormField(
      controller: controllers[field.key],
      decoration: _inputDecoration(field),
      keyboardType:
      field.type == "number" ? TextInputType.number : TextInputType.text,
      maxLength: field.maxLength,
      validator: (val) {
        if (field.required && (val == null || val.isEmpty)) {
          return "Required";
        }
        return null;
      },
    );
  }


  Widget _buildFieldByType(FieldConfig field) {
    switch (field.uiControlType) {
      case "date_picker":
        return _buildDatePicker(field);

      case "year_picker":
        return _buildYearPicker(field);

      case "text_input":
      default:
        return _buildTextInput(field);
    }
  }
  /// Build dynamic input fields from config
  Widget buildFormFields() {
    if (serviceConfig == null) return const SizedBox.shrink();

    return Column(
      children: serviceConfig!.fields.map((field) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: field.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    if (field.required)
                      const TextSpan(
                        text: " *",
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildFieldByType(field),
            ],
          ),
        );
      }).toList(),
    );
  }


  /// Builds the JSON body for DigiLocker style API
  /*
  Map<String, dynamic> getDocInputAPI_Params() {
    final bodyParams = <String, dynamic>{};

    for (final field in serviceConfig!.fields) {
      bodyParams[field.key] = controllers[field.key]?.text.trim();
    }

    return {
      "orgid": serviceConfig!.orgid,
      "doctype": serviceConfig!.endpointType,
      "parameters": bodyParams,
    };
  }
*/

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    //try {

    final pref = await SharedPreferences.getInstance();
    final accessToken = await pref.getString(AppConstants.tokenKey) ?? "";
    // Check serviceType in config ("custom" for Trade License, otherwise digilocker)
    if (serviceConfig!.serviceType == "custom") {
      await _callCustomServiceApi(accessToken);
    } else {
      //await _callDigiLockerPull(accessToken);
    }
    // } catch (e) {
    //   Fluttertoast.showToast(msg: "Something went wrong");
    //   debugPrint("❌ Submit error: $e");
    // } finally {
    //   if (mounted) setState(() => isLoading = false);
    // }
  }

  String _getCustomEndpoint(String docType) {
    switch (docType.toLowerCase()) {
      case 'trade license':
        return AppConstants.tradeLicenseEndpoint;
      case 'fire noc':
        return AppConstants.fireNocEndpoint;
      case 'fire safety certificate':
        return AppConstants.fireSafetyEndpoint;
      case 'water certificate':
        return AppConstants.waterCertificateEndpoint;
      case 'water noc':
        return AppConstants.waterNocEndpoint;
      case 'property noc':
        return AppConstants.propertyNocEndpoint;
      case 'new property application':
        return AppConstants.newpropertyEndpoint;
      case 'marriage certificate':
        return AppConstants.marriageCertificateEndpoint;
      case 'sewerage connection':
        return AppConstants.sewerageConnectionEndpoint;
      case 'tree cutting/transit certificate':
        return AppConstants.treeCuttingTransitEndpoint;
      case 'property tax receipt':
        return AppConstants.propertyTaxReceiptEndpoint;
      case 'hoarding license':
        return AppConstants.hoardingLicenseEndpoint;
      case 'property mutation':
        return AppConstants.propertyMutationEndpoint;
      case 'water tax receipt':
        return AppConstants.waterTaxReceiptEndpoint;
      default:
        throw Exception("Unknown custom service: $docType");
    }
  }

  Map<String, dynamic> _buildCustomPayload() {
    final payload = <String, dynamic>{};
    for (final field in serviceConfig!.fields) {
      payload[field.key] = controllers[field.key]!.text.trim();
    }
    for (final field in serviceConfig!.fields) {
      if (field.certificatetype != null && field.certificatename != null) {
        payload[field.certificatetype!] = field.certificatename!;
      }
    }

    payload['language'] = 'en';
    return payload;
  }

  /// Calls your custom API (Trade License, etc.)
  Future<void> _callCustomServiceApi(String accessToken) async {
    final endpoint = _getCustomEndpoint(widget.docType);
    final apiService = context.read<ApiService>();
    try {
      final response = await apiService.submitCustomService(
        accessToken: accessToken,
        endpoint: endpoint,
        payload: _buildCustomPayload(),
      );
      setState(() => isLoading = false);
      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['pdf'] != null) {
        final String base64Pdf = response['data']['pdf'];
        final String docID = response['data']['id'];
        print("doc idddd -${docID}");
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentPreview(
              title: widget.docType,
              date: "",
              docId: docID,
              pdfString: base64Pdf,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: response['message']);
      }
    } on NoInternetException catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "${e.toString()}");
    } on Exception catch (e){
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "${e.toString()}");
    }
  }

/// Calls DigiLocker API pullDocument endpoint
/*
  Future<void> _callDigiLockerPull(String accessToken) async {
    final storedUserId =
        await FlutterSecureStorage().read(key: AppConstants.userIdKey) ?? "";

    final url =
        '${AppConstants.baseUrl}${AppConstants.pullDocumentEndpoint(storedUserId)}';

    debugPrint("📤 pull URL: $url");
    debugPrint("📤 payload: ${jsonEncode(getDocInputAPI_Params())}");

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(getDocInputAPI_Params()),
    );

    debugPrint("📥 pull status: ${response.statusCode}");
    debugPrint("📥 pull body: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (body['success'] == true && body['data'] != null) {
        final Document objDocument = Document.fromJson(
          body['data'] as Map<String, dynamic>,
        );

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentPreview(
              title: objDocument.name ?? "",
              date: objDocument.date ?? "",
              uri: objDocument.uri,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: body['message'] ?? "API returned success=false",
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "HTTP error ${response.statusCode}",
      );
    }
  }
*/
}

