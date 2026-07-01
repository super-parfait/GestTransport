import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/site_record.dart';
import '../../data/models/site_upsert_request.dart';
import '../../domain/repositories/sites_repository.dart';

class SitesManagementController extends ChangeNotifier {
  final SitesRepository _repository;

  List<SiteRecord> _sites = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  SitesManagementController(this._repository);

  List<SiteRecord> get sites => _sites;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> loadSites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sites = _sortSites(await _repository.fetchSites());
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Chargement des sites impossible.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSite(SiteUpsertRequest request) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createSite(request);
      _sites = _sortSites([..._sites, created]);
      _successMessage = 'Site enregistré.';
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Création du site impossible.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateSite(String siteId, SiteUpsertRequest request) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateSite(siteId, request);
      _sites = _sortSites(
        _sites
            .map((site) => site.id == siteId ? updated : site)
            .toList(growable: false),
      );
      _successMessage = 'Site mis à jour.';
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Mise à jour du site impossible.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSite(String siteId) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.deleteSite(siteId);
      _sites =
          _sites.where((site) => site.id != siteId).toList(growable: false);
      _successMessage = 'Site supprimé.';
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Suppression du site impossible.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  List<SiteRecord> _sortSites(List<SiteRecord> sites) {
    final sorted = List<SiteRecord>.from(sites);
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }
}
