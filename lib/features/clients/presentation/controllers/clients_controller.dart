import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/client_model.dart';
import '../../domain/repositories/clients_repository.dart';

class ClientsController extends ChangeNotifier {
  final ClientsRepository _repository;

  List<ClientModel> _clients = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  ClientsController(this._repository);

  List<ClientModel> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<ClientModel> get filteredClients {
    final normalized = _searchQuery.trim().toLowerCase();
    if (normalized.isEmpty) {
      return _clients;
    }

    return _clients.where((client) {
      return client.name.toLowerCase().contains(normalized) ||
          client.phone.contains(_searchQuery);
    }).toList();
  }

  int get debtorCount =>
      filteredClients.where((client) => client.isDebtor).length;

  double get totalDebt => filteredClients.fold<double>(
        0,
        (sum, client) => sum + client.balance,
      );

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _clients = await _repository.fetchClients();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Chargement des clients impossible.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }
}
