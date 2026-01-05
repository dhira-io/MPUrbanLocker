class Document {
  final String id;
  final String? userId;
  final String? name;
  final String? type;
  final String? size;
  final String? date;
  final String? parent;
  final String? uri;
  final String? doctype;
  final String? description;
  final String? issuerid;
  final String? issuer;
  final List<String>? mimeType;
  final String? createdAt;
  final String? updatedAt;

  Document({
    required this.id,
    this.userId,
    this.name,
    this.type,
    this.size,
    this.date,
    this.parent,
    this.uri,
    this.doctype,
    this.description,
    this.issuerid,
    this.issuer,
    this.mimeType,
    this.createdAt,
    this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    List<String>? mimeTypes;
    final mimeTypeData = json['mimeType'] ?? json['mime_type'];
    if (mimeTypeData != null) {
      if (mimeTypeData is List) {
        mimeTypes = mimeTypeData.map((e) => e.toString()).toList();
      } else if (mimeTypeData is String) {
        mimeTypes = [mimeTypeData];
      }
    }

    return Document(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString(),
      name: json['name'] as String?,
      type: json['type'] as String?,
      size: json['size']?.toString(),
      date: json['date'] as String?,
      parent: json['parent'] as String?,
      uri: json['uri'] as String?,
      doctype: json['doctype'] as String?,
      description: json['description'] as String?,
      issuerid: json['issuerid'] as String?,
      issuer: json['issuer'] as String?,
      mimeType: mimeTypes,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'size': size,
      'date': date,
      'parent': parent,
      'uri': uri,
      'doctype': doctype,
      'description': description,
      'issuerid': issuerid,
      'issuer': issuer,
      'mimeType': mimeType,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Document(id: $id, name: $name, type: $type, issuer: $issuer)';
  }
}

class DocumentCategory {
  final String category;
  final List<CategoryDocument> documents;

  DocumentCategory({
    required this.category,
    required this.documents,
  });

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    return DocumentCategory(
      category: json['category'] as String,
      documents: (json['documents'] as List)
          .map((e) => CategoryDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'documents': documents.map((e) => e.toJson()).toList(),
    };
  }
}

class CategoryDocument {
  final String? docType;
  final String? documentDescription;
  final String? departmentName;
  final String? issuer;
  final String? issuerid;
  final String? orgid;
  final String? uri;
  final bool issued;
  final String? date;
  final List<String>? mimeType;
  final bool? requiresInput;
  final List<RequiredField>? requiredFields;
  final int? issuerCount;
  final List<IssuerOption>? availableIssuers;

  CategoryDocument({
    this.docType,
    this.documentDescription,
    this.departmentName,
    this.issuer,
    this.issuerid,
    this.orgid,
    this.uri,
    required this.issued,
    this.date,
    this.mimeType,
    this.requiresInput,
    this.requiredFields,
    this.issuerCount,
    this.availableIssuers,
  });

  factory CategoryDocument.fromJson(Map<String, dynamic> json) {
    List<String>? mimeTypes;
    if (json['mime_type'] != null) {
      if (json['mime_type'] is List) {
        mimeTypes = (json['mime_type'] as List).map((e) => e.toString()).toList();
      } else if (json['mime_type'] is String) {
        mimeTypes = [json['mime_type'] as String];
      }
    }

    return CategoryDocument(
      docType: json['doc_type'] as String?,
      documentDescription: json['document_description'] as String?,
      departmentName: json['department_name'] as String?,
      issuer: json['issuer'] as String?,
      issuerid: json['issuerid'] as String?,
      orgid: json['orgid'] as String?,
      uri: json['uri'] as String?,
      issued: json['issued'] as bool? ?? false,
      date: json['date'] as String?,
      mimeType: mimeTypes,
      requiresInput: json['requires_input'] as bool?,
      requiredFields: json['required_fields'] != null
          ? (json['required_fields'] as List)
              .map((e) => RequiredField.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      issuerCount: json['issuer_count'] as int?,
      availableIssuers: json['available_issuers'] != null
          ? (json['available_issuers'] as List)
              .map((e) => IssuerOption.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doc_type': docType,
      'document_description': documentDescription,
      'department_name': departmentName,
      'issuer': issuer,
      'issuerid': issuerid,
      'orgid': orgid,
      'uri': uri,
      'issued': issued,
      'date': date,
      'mime_type': mimeType,
      'requires_input': requiresInput,
      'required_fields': requiredFields?.map((e) => e.toJson()).toList(),
      'issuer_count': issuerCount,
      'available_issuers': availableIssuers?.map((e) => e.toJson()).toList(),
    };
  }
}

class RequiredField {
  final String fieldName;
  final String label;
  final String fieldType;
  final String? example;
  final List<String>? options;
  final bool required;

  RequiredField({
    required this.fieldName,
    required this.label,
    required this.fieldType,
    this.example,
    this.options,
    required this.required,
  });

  factory RequiredField.fromJson(Map<String, dynamic> json) {
    return RequiredField(
      fieldName: json['field_name'] as String,
      label: json['label'] as String,
      fieldType: json['field_type'] as String,
      example: json['example'] as String?,
      options: json['options'] != null
          ? (json['options'] as List).map((e) => e.toString()).toList()
          : null,
      required: json['required'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field_name': fieldName,
      'label': label,
      'field_type': fieldType,
      'example': example,
      'options': options,
      'required': required,
    };
  }
}

class IssuerOption {
  final String orgid;
  final String issuer;
  final String? departmentName;

  IssuerOption({
    required this.orgid,
    required this.issuer,
    this.departmentName,
  });

  factory IssuerOption.fromJson(Map<String, dynamic> json) {
    return IssuerOption(
      orgid: json['orgid'] as String,
      issuer: json['issuer'] as String,
      departmentName: json['department_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orgid': orgid,
      'issuer': issuer,
      'department_name': departmentName,
    };
  }
}
