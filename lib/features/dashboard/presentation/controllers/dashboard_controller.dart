import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/dashboard_overview.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardController extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardOverview? _overview;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardController(this._repository);

  DashboardOverview? get overview => _overview;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _overview = await _repository.fetchOverview();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Chargement du tableau de bord impossible.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
