import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/driver_model.dart';
import '../../data/models/driver_upsert_request.dart';
import '../../domain/repositories/drivers_repository.dart';

class DriversController extends ChangeNotifier {
  final DriversRepository _repository;

  List<DriverModel> _drivers = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  String _searchQuery = '';

  DriversController(this._repository);

  List<DriverModel> get drivers => _drivers;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get searchQuery => _searchQuery;

  List<DriverModel> get filteredDrivers {
    final normalized = _searchQuery.trim().toLowerCase();
    if (normalized.isEmpty) {
      return _drivers;
    }

    return _drivers.where((driver) {
      return driver.name.toLowerCase().contains(normalized) ||
          driver.phone.contains(_searchQuery);
    }).toList(growable: false);
  }

  int get activeCount =>
      filteredDrivers.where((driver) => driver.isActive).length;

  int get inactiveCount =>
      filteredDrivers.where((driver) => !driver.isActive).length;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _drivers = _sortDrivers(await _repository.fetchDrivers());
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Chargement des chauffeurs impossible.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<bool> createDriver(DriverUpsertRequest request) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createDriver(request);
      _drivers = _sortDrivers([..._drivers, created]);
      _successMessage = 'Chauffeur enregistré.';
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Création du chauffeur impossible.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateDriver(
    String driverId,
    DriverUpsertRequest request,
  ) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateDriver(driverId, request);
      _drivers = _sortDrivers(
        _drivers
            .map((driver) => driver.id == driverId ? updated : driver)
            .toList(growable: false),
      );
      _successMessage = 'Chauffeur mis à jour.';
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Mise à jour du chauffeur impossible.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDriver(String driverId) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.deleteDriver(driverId);
      _drivers = _drivers
          .where((driver) => driver.id != driverId)
          .toList(growable: false);
      _successMessage = 'Chauffeur supprimé.';
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Suppression du chauffeur impossible.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  List<DriverModel> _sortDrivers(List<DriverModel> drivers) {
    final sorted = List<DriverModel>.from(drivers);
    sorted.sort((a, b) {
      final byUpdate = b.updatedAt.compareTo(a.updatedAt);
      if (byUpdate != 0) {
        return byUpdate;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }
}
