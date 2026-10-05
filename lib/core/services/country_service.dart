import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/country_model.dart';

class CountryService {
  CountryService._();

  static List<CountryModel>? _cachedCountries;

  static Future<List<CountryModel>> getCountries() async {
    if (_cachedCountries != null && _cachedCountries!.isNotEmpty) {
      return _cachedCountries!;
    }

    try {
      final jsonStr = await rootBundle.loadString('assets/data/country.json');
      final dynamic list = jsonDecode(jsonStr);
      if (list is List) {
        _cachedCountries = list
            .whereType<Map>()
            .map((item) => CountryModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        return _cachedCountries!;
      }
    } catch (_) {}

    return _cachedCountries ?? const [];
  }

  static Future<CountryModel?> findByName(String? name) async {
    if (name == null || name.trim().isEmpty) return null;
    final countries = await getCountries();
    final lower = name.trim().toLowerCase();
    for (final c in countries) {
      if (c.name.toLowerCase() == lower) return c;
    }
    return null;
  }

  static Future<CountryModel?> findByCode(String? code) async {
    if (code == null || code.trim().isEmpty) return null;
    final countries = await getCountries();
    final upper = code.trim().toUpperCase();
    for (final c in countries) {
      if (c.code.toUpperCase() == upper) return c;
    }
    return null;
  }
}
