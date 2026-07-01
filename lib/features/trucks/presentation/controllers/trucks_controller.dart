import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/truck_model.dart';
import '../../data/models/truck_upsert_request.dart';
import '../../domain/repositories/trucks_repository.dart';

class TrucksController extends ChangeNotifier {
  final TrucksRepository _repository;

  List<TruckModel> _trucks = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  TrucksController(this._repository);

  List<TruckModel> get trucks => _trucks;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  int get activeCount => _trucks.where((truck) {
        final status = truck.status.trim().toUpperCase();
        return status == 'ACTIVE' ||
            status == 'TRAVELING' ||
            status == 'ACTIF' ||
            status == 'EN_VOYAGE';
      }).length;

  int get alertsCount => _trucks.where((truck) => truck.hasAlerts).length;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _trucks = _sortTrucks(await _repository.fetchTrucks());
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Chargement des camions impossible.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTruck(TruckUpsertRequest request) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createTruck(request);
      _trucks = _sortTrucks([..._trucks, created]);
      _successMessage = 'Camion enregistré.';
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Création du camion impossible.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateTruck(
    String truckId,
    TruckUpsertRequest request,
  ) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateTruck(truckId, request);
      _trucks = _sortTrucks(
        _trucks
            .map((truck) => truck.id == truckId ? updated : truck)
            .toList(growable: false),
      );
      _successMessage = 'Camion mis à jour.';
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Mise à jour du camion impossible.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTruck(String truckId) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.deleteTruck(truckId);
      _trucks =
          _trucks.where((truck) => truck.id != truckId).toList(growable: false);
      _successMessage = 'Camion supprimé.';
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Suppression du camion impossible.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  List<TruckModel> _sortTrucks(List<TruckModel> trucks) {
    final sorted = List<TruckModel>.from(trucks);
    sorted.sort((a, b) {
      final byUpdate = b.updatedAt.compareTo(a.updatedAt);
      if (byUpdate != 0) {
        return byUpdate;
      }
      return a.plate.toLowerCase().compareTo(b.plate.toLowerCase());
    });
    return sorted;
  }
}
