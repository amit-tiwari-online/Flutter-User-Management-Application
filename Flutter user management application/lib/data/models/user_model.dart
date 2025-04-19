import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User extends Equatable {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String email;
  
  @HiveField(3)
  final String phone;
  
  @HiveField(4)
  final String address;
  
  @HiveField(5)
  final Company? company;
  
  @HiveField(6)
  final String? website;
  
  @HiveField(7)
  final Geo? geo;
  
  @HiveField(8)
  final bool isLocal;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.company,
    this.website,
    this.geo,
    this.isLocal = false,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    final addressData = json['address'] as Map<String, dynamic>?;
    final companyData = json['company'] as Map<String, dynamic>?;
    final geoData = addressData?['geo'] as Map<String, dynamic>?;
    
    // Extract address as a string from nested address object
    String formattedAddress = '';
    if (addressData != null) {
      final street = addressData['street'] as String?;
      final suite = addressData['suite'] as String?;
      final city = addressData['city'] as String?;
      final zipcode = addressData['zipcode'] as String?;
      
      formattedAddress = [
        if (street != null) street,
        if (suite != null) suite,
        if (city != null) city,
        if (zipcode != null) zipcode,
      ].join(', ');
    } else {
      // If address is already a string, use it
      formattedAddress = json['address'] as String? ?? '';
    }
    
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: formattedAddress,
      website: json['website'] as String?,
      company: companyData != null ? Company.fromJson(companyData) : null,
      geo: geoData != null ? Geo.fromJson(geoData) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'company': company?.toJson(),
      'website': website,
      'geo': geo?.toJson(),
      'isLocal': isLocal,
    };
  }
  
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    Company? company,
    String? website,
    Geo? geo,
    bool? isLocal,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      company: company ?? this.company,
      website: website ?? this.website,
      geo: geo ?? this.geo,
      isLocal: isLocal ?? this.isLocal,
    );
  }
  
  @override
  List<Object?> get props => [
    id, 
    name, 
    email, 
    phone, 
    address, 
    website, 
    company, 
    geo,
    isLocal,
  ];
}

@HiveType(typeId: 1)
class Company extends Equatable {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final String? catchPhrase;
  
  @HiveField(2)
  final String? bs;
  
  const Company({
    required this.name,
    this.catchPhrase,
    this.bs,
  });
  
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] as String,
      catchPhrase: json['catchPhrase'] as String?,
      bs: json['bs'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'catchPhrase': catchPhrase,
      'bs': bs,
    };
  }
  
  @override
  List<Object?> get props => [name, catchPhrase, bs];
}

@HiveType(typeId: 2)
class Geo extends Equatable {
  @HiveField(0)
  final String lat;
  
  @HiveField(1)
  final String lng;
  
  const Geo({
    required this.lat,
    required this.lng,
  });
  
  factory Geo.fromJson(Map<String, dynamic> json) {
    return Geo(
      lat: json['lat'].toString(),
      lng: json['lng'].toString(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
  
  @override
  List<Object?> get props => [lat, lng];
}