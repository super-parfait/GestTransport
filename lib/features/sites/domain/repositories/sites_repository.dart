import '../../data/models/site_record.dart';
import '../../data/models/site_upsert_request.dart';

abstract class SitesRepository {
  Future<List<SiteRecord>> fetchSites();

  Future<SiteRecord> createSite(SiteUpsertRequest request);

  Future<SiteRecord> updateSite(String siteId, SiteUpsertRequest request);

  Future<void> deleteSite(String siteId);
}
