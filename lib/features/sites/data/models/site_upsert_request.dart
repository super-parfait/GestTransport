import 'site_record.dart';

class SiteUpsertRequest {
  final String name;
  final String type;
  final String location;
  final String contact;
  final int currentPrice;
  final String notes;

  const SiteUpsertRequest({
    required this.name,
    required this.type,
    required this.location,
    required this.contact,
    required this.currentPrice,
    required this.notes,
  });

  factory SiteUpsertRequest.fromSite(SiteRecord site) {
    return SiteUpsertRequest(
      name: site.name,
      type: site.type,
      location: site.location,
      contact: site.contact,
      currentPrice: site.currentPrice,
      notes: site.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'type': type.trim(),
      'location': _nullable(location),
      'contact': _nullable(contact),
      'currentPrice': currentPrice,
      'notes': _nullable(notes),
    };
  }

  static String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
