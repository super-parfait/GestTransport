import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/truck_model.dart';
import '../../domain/repositories/trucks_repository.dart';

class TrucksController extends ChangeNotifier {
  final TrucksRepository _repository;

  List<TruckModel> _trucks = const [];
  bool _isLoading = false;
  String? _errorMessage;

  TrucksController(this._repository);

  List<TruckModel> get trucks => _trucks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
    notifyListeners();

    try {
      _trucks = await _repository.fetchTrucks();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Chargement des camions impossible.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
