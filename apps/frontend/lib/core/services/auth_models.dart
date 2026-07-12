class OrganizationProfile {
  const OrganizationProfile({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
  });

  final String id;
  final String name;
  final String code;
  final String status;

  factory OrganizationProfile.fromJson(Map<String, dynamic> json) {
    return OrganizationProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'code': code,
        'status': status,
      };
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.status,
    required this.permissions,
    required this.organizations,
    this.contactNumber,
  });

  final String id;
  final String fullName;
  final String email;
  final String? contactNumber;
  final String status;
  final List<String> permissions;
  final List<OrganizationProfile> organizations;

  String get organizationName =>
      organizations.isEmpty ? 'No organization assigned' : organizations.first.name;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawOrganizations =
        json['organizations'] as List<dynamic>? ?? <dynamic>[];
    return AuthUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      contactNumber: json['contactNumber'] as String?,
      status: json['status'] as String,
      permissions: (json['permissions'] as List<dynamic>? ?? <dynamic>[])
          .cast<String>(),
      organizations: rawOrganizations
          .map((dynamic organization) => OrganizationProfile.fromJson(
              (organization as Map<dynamic, dynamic>).cast<String, dynamic>()))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'fullName': fullName,
        'email': email,
        'contactNumber': contactNumber,
        'status': status,
        'permissions': permissions,
        'organizations': organizations
            .map((OrganizationProfile organization) => organization.toJson())
            .toList(),
      };
}
