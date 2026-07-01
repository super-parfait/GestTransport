import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/client_model.dart';
import '../../data/models/client_upsert_request.dart';
import '../../domain/repositories/clients_repository.dart';

class ClientsController extends ChangeNotifier {
  final ClientsRepository _repository;

  List<ClientModel> _clients = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  String _searchQuery = '';

  ClientsController(this._repository);

  List<ClientModel> get clients => _clients;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
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
    _successMessage = null;
    notifyListeners();

    try {
      _clients = _sortClients(await _repository.fetchClients());
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

  Future<bool> createClient(ClientUpsertRequest request) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createClient(request);
      _clients = _sortClients([..._clients, created]);
      _successMessage = 'Client enregistré.';
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Création du client impossible.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateClient(
    String clientId,
    ClientUpsertRequest request,
  ) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateClient(clientId, request);
      _clients = _sortClients(
        _clients
            .map((client) => client.id == clientId ? updated : client)
            .toList(growable: false),
      );
      _successMessage = 'Client mis à jour.';
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Mise à jour du client impossible.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteClient(String clientId) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.deleteClient(clientId);
      _clients = _clients
          .where((client) => client.id != clientId)
          .toList(growable: false);
      _successMessage = 'Client supprimé.';
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Suppression du client impossible.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  List<ClientModel> _sortClients(List<ClientModel> clients) {
    final sorted = List<ClientModel>.from(clients);
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
