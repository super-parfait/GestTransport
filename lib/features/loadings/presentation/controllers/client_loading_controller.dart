import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../clients/data/models/client_model.dart';
import '../../../clients/domain/repositories/clients_repository.dart';
import '../../../sites/data/models/site_record.dart';
import '../../../sites/domain/repositories/sites_repository.dart';
import '../../../trucks/data/models/truck_model.dart';
import '../../../trucks/domain/repositories/trucks_repository.dart';
import '../../data/models/create_loading_request.dart';
import '../../data/models/loading_driver_option.dart';
import '../../data/models/loading_record.dart';
import '../../domain/repositories/loadings_repository.dart';

class ClientLoadingController extends ChangeNotifier {
  final LoadingsRepository _loadingsRepository;
  final ClientsRepository _clientsRepository;
  final TrucksRepository _trucksRepository;
  final SitesRepository _sitesRepository;

  List<ClientModel> _clients = const [];
  List<TruckModel> _trucks = const [];
  List<SiteRecord> _sites = const [];
  List<LoadingDriverOption> _drivers = const [];
  List<LoadingRecord> _loadings = const [];
  bool _isLoadingReferences = false;
  bool _isLoadingLoadings = false;
  bool _isSubmitting = false;
  String? _referencesErrorMessage;
  String? _loadingsErrorMessage;
  String? _submitErrorMessage;
  String? _successMessage;

  ClientLoadingController({
    required LoadingsRepository loadingsRepository,
    required ClientsRepository clientsRepository,
    required TrucksRepository trucksRepository,
    required SitesRepository sitesRepository,
  })  : _loadingsRepository = loadingsRepository,
        _clientsRepository = clientsRepository,
        _trucksRepository = trucksRepository,
        _sitesRepository = sitesRepository;

  List<ClientModel> get clients => _clients;
  List<ClientModel> get selectableClients =>
      _clients.where((client) => client.hasUsableId).toList(growable: false);
  List<TruckModel> get trucks => _trucks;
  List<SiteRecord> get sites => _sites;
  List<LoadingDriverOption> get drivers => _drivers;
  List<LoadingRecord> get loadings => _loadings;
  bool get isLoadingReferences => _isLoadingReferences;
  bool get isLoadingLoadings => _isLoadingLoadings;
  bool get isSubmitting => _isSubmitting;
  String? get referencesErrorMessage => _referencesErrorMessage;
  String? get loadingsErrorMessage => _loadingsErrorMessage;
  String? get submitErrorMessage => _submitErrorMessage;
  String? get formErrorMessage =>
      _submitErrorMessage ?? _referencesErrorMessage;
  String? get successMessage => _successMessage;
  bool get hasLegacyClients => _clients.any((client) => !client.hasUsableId);

  Future<void> loadInitialData() async {
    await Future.wait([
      loadReferences(),
      loadLoadings(),
    ]);
  }

  Future<void> loadReferences() async {
    _isLoadingReferences = true;
    _referencesErrorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _clientsRepository.fetchClients(),
        _trucksRepository.fetchTrucks(),
        _sitesRepository.fetchSites(),
      ]);
      _clients = results[0] as List<ClientModel>;
      _trucks = results[1] as List<TruckModel>;
      _sites = results[2] as List<SiteRecord>;
      _drivers = _extractDrivers(_trucks);
    } on ApiException catch (error) {
      _referencesErrorMessage = error.message;
    } catch (_) {
      _referencesErrorMessage =
          'Chargement des clients, camions et sites impossible.';
    } finally {
      _isLoadingReferences = false;
      notifyListeners();
    }
  }

  Future<void> loadLoadings() async {
    _isLoadingLoadings = true;
    _loadingsErrorMessage = null;
    notifyListeners();

    try {
      _loadings = _sortLoadings(await _loadingsRepository.fetchLoadings());
    } on ApiException catch (error) {
      _loadingsErrorMessage = error.message;
    } catch (_) {
      _loadingsErrorMessage = 'Chargement des opérations impossible.';
    } finally {
      _isLoadingLoadings = false;
      notifyListeners();
    }
  }

  Future<LoadingRecord?> submit({
    required CreateLoadingRequest request,
    String? proofPath,
  }) async {
    _isSubmitting = true;
    _submitErrorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      var payload = request;

      if (proofPath != null && proofPath.trim().isNotEmpty) {
        final proofUrl =
            await _loadingsRepository.uploadProof(proofPath.trim());
        payload = CreateLoadingRequest(
          date: request.date,
          type: request.type,
          clientId: request.clientId,
          siteId: request.siteId,
          truckId: request.truckId,
          driverId: request.driverId,
          voucherNumber: request.voucherNumber,
          destination: request.destination,
          quantity: request.quantity,
          tripsCount: request.tripsCount,
          purchasePrice: request.purchasePrice,
          salePrice: request.salePrice,
          transportPrice: request.transportPrice,
          fuelExpense: request.fuelExpense,
          roadFees: request.roadFees,
          otherFees: request.otherFees,
          proofUrl: proofUrl,
          status: request.status,
        );
      }

      final created = await _loadingsRepository.createLoading(payload);
      _loadings = _sortLoadings([created, ..._loadings]);
      _successMessage = created.status.trim().toUpperCase() == 'BROUILLON'
          ? 'Brouillon enregistré.'
          : 'Chargement enregistré.';
      return created;
    } on ApiException catch (error) {
      _submitErrorMessage = error.message;
      return null;
    } catch (_) {
      _submitErrorMessage = 'Enregistrement du chargement impossible.';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  ClientModel? clientById(String clientId) {
    for (final client in _clients) {
      if (client.id == clientId) {
        return client;
      }
    }
    return null;
  }

  TruckModel? truckById(String truckId) {
    for (final truck in _trucks) {
      if (truck.id == truckId) {
        return truck;
      }
    }
    return null;
  }

  SiteRecord? siteById(String siteId) {
    for (final site in _sites) {
      if (site.id == siteId) {
        return site;
      }
    }
    return null;
  }

  LoadingDriverOption? driverById(String driverId) {
    for (final driver in _drivers) {
      if (driver.id == driverId) {
        return driver;
      }
    }
    return null;
  }

  LoadingDriverOption? driverForTruck(String truckId) {
    for (final driver in _drivers) {
      if (driver.truckId == truckId) {
        return driver;
      }
    }
    return null;
  }

  bool isSelectableClientId(String? clientId) {
    final normalized = clientId?.trim() ?? '';
    if (normalized.isEmpty) {
      return false;
    }
    return selectableClients.any((client) => client.id == normalized);
  }

  bool isSelectableDriverId(String? driverId) {
    final normalized = driverId?.trim() ?? '';
    if (normalized.isEmpty) {
      return false;
    }
    return _drivers.any((driver) => driver.id == normalized);
  }

  List<LoadingDriverOption> _extractDrivers(List<TruckModel> trucks) {
    final seen = <String>{};
    final drivers = <LoadingDriverOption>[];

    for (final truck in trucks) {
      final driverName = truck.driver.trim();
      if (driverName.isEmpty) {
        continue;
      }

      final driverId = truck.driverId.trim();
      if (driverId.isEmpty) {
        continue;
      }
      if (seen.contains(driverId)) {
        continue;
      }

      final candidate = LoadingDriverOption(
        id: driverId,
        name: driverName,
        phone: truck.phone,
        truckId: truck.id,
        truckRegistration: truck.plate,
      );
      if (!candidate.hasUsableId) {
        continue;
      }

      seen.add(driverId);
      drivers.add(candidate);
    }

    return drivers;
  }

  List<LoadingRecord> _sortLoadings(List<LoadingRecord> items) {
    final sorted = List<LoadingRecord>.from(items);
    sorted.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) {
        return byDate;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }
}
