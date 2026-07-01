import '../models/site_record.dart';
import '../models/site_upsert_request.dart';

class SitesMockDataSource {
  final List<SiteRecord> _sites = [
    SiteRecord(
      id: 'mock-site-banco',
      name: 'Carrière du Banco',
      type: 'CARRIERE',
      location: 'Yopougon, Abidjan',
      contact: '0700000000',
      currentPrice: 150000,
      notes: 'Site démo',
      createdAt: DateTime(2026, 6, 30, 9),
      updatedAt: DateTime(2026, 6, 30, 9),
    ),
    SiteRecord(
      id: 'mock-site-cadera',
      name: 'CADERAC',
      type: 'USINE',
      location: 'Vridi, Abidjan',
      contact: '0711111111',
      currentPrice: 250000,
      notes: '',
      createdAt: DateTime(2026, 6, 30, 10),
      updatedAt: DateTime(2026, 6, 30, 10),
    ),
  ];

  Future<List<SiteRecord>> fetchSites() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _sortedSites();
  }

  Future<SiteRecord> createSite(SiteUpsertRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    final site = SiteRecord(
      id: 'mock-site-${now.microsecondsSinceEpoch}',
      name: request.name.trim(),
      type: request.type.trim(),
      location: request.location.trim(),
      contact: request.contact.trim(),
      currentPrice: request.currentPrice,
      notes: request.notes.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _sites.add(site);
    return site;
  }

  Future<SiteRecord> updateSite(
    String siteId,
    SiteUpsertRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _sites.indexWhere((site) => site.id == siteId);
    if (index < 0) {
      throw StateError('Site introuvable');
    }

    final updated = _sites[index].copyWith(
      name: request.name.trim(),
      type: request.type.trim(),
      location: request.location.trim(),
      contact: request.contact.trim(),
      currentPrice: request.currentPrice,
      notes: request.notes.trim(),
      updatedAt: DateTime.now(),
    );
    _sites[index] = updated;
    return updated;
  }

  Future<void> deleteSite(String siteId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _sites.removeWhere((site) => site.id == siteId);
  }

  List<SiteRecord> _sortedSites() {
    final cloned = List<SiteRecord>.from(_sites);
    cloned.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return cloned;
  }
}
