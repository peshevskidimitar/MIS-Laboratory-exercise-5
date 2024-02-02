import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:json_annotation/json_annotation.dart';

part 'locations.g.dart';

@JsonSerializable()
class Laboratory {
  Laboratory({
    required this.id,
    required this.lat,
    required this.lng,
    required this.name,
  });

  factory Laboratory.fromJson(Map<String, dynamic> json) =>
      _$LaboratoryFromJson(json);

  Map<String, dynamic> toJson() => _$LaboratoryToJson(this);

  final int id;
  final double lat;
  final double lng;
  final String name;
}

@JsonSerializable()
class Locations {
  Locations({
    required this.laboratories,
  });

  factory Locations.fromJson(Map<String, dynamic> json) =>
      _$LocationsFromJson(json);

  Map<String, dynamic> toJson() => _$LocationsToJson(this);

  final List<Laboratory> laboratories;
}

Future<Locations> getLaboratories() async {
  return Locations.fromJson(
    json.decode(
      await rootBundle.loadString('assets/locations.json'),
    ) as Map<String, dynamic>,
  );
}
