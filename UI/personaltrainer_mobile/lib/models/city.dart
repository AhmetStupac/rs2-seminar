class City {
  int? id;
  String? name;
  int? countryId;
  String? countryName;

  City({
    this.id,
    this.name,
    this.countryId,
    this.countryName,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: (json['id'] as num?)?.toInt(),
        name: json['name'] as String?,
        countryId: (json['countryId'] as num?)?.toInt(),
        countryName: json['countryName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'countryId': countryId,
        'countryName': countryName,
      };
}
