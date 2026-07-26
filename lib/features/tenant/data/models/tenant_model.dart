
class TenantModel {
  final int id;
  final String name;
  final String description;
  final String code;

  TenantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.code,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        code: json['code']
    );
  }


}