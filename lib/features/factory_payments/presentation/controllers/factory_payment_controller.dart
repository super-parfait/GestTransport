import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/create_factory_payment_request.dart';
import '../../data/models/factory_payment_record.dart';
import '../../data/models/factory_site_option.dart';
import '../../domain/repositories/factory_payments_repository.dart';

class FactoryPaymentController extends ChangeNotifier {
  final FactoryPaymentsRepository _repository;

  List<FactorySiteOption> _sites = const [];
  List<FactoryPaymentRecord> _payments = const [];
  bool _isLoadingSites = false;
  bool _isLoadingPayments = false;
  bool _isSubmitting = false;
  String? _sitesErrorMessage;
  String? _paymentsErrorMessage;
  String? _submitErrorMessage;
  String? _successMessage;

  FactoryPaymentController(this._repository);

  List<FactorySiteOption> get sites => _sites;
  List<FactoryPaymentRecord> get payments => _payments;
  bool get isLoadingSites => _isLoadingSites;
  bool get isLoadingPayments => _isLoadingPayments;
  bool get isSubmitting => _isSubmitting;
  String? get sitesErrorMessage => _sitesErrorMessage;
  String? get paymentsErrorMessage => _paymentsErrorMessage;
  String? get submitErrorMessage => _submitErrorMessage;
  String? get formErrorMessage => _submitErrorMessage ?? _sitesErrorMessage;
  String? get successMessage => _successMessage;

  FactoryPaymentRecord? paymentById(String paymentId) {
    for (final payment in _payments) {
      if (payment.id == paymentId) {
        return payment;
      }
    }

    return null;
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      loadSites(),
      loadPayments(),
    ]);
  }

  Future<void> loadSites() async {
    _isLoadingSites = true;
    _sitesErrorMessage = null;
    notifyListeners();

    try {
      _sites = await _repository.fetchSites();
    } on ApiException catch (error) {
      _sitesErrorMessage = error.message;
    } catch (_) {
      _sitesErrorMessage = 'Chargement des carrières et usines impossible.';
    } finally {
      _isLoadingSites = false;
      notifyListeners();
    }
  }

  Future<void> loadPayments() async {
    _isLoadingPayments = true;
    _paymentsErrorMessage = null;
    notifyListeners();

    try {
      _payments = _sortPayments(await _repository.fetchPayments());
    } on ApiException catch (error) {
      _paymentsErrorMessage = error.message;
    } catch (_) {
      _paymentsErrorMessage = 'Chargement des versements impossible.';
    } finally {
      _isLoadingPayments = false;
      notifyListeners();
    }
  }

  Future<FactoryPaymentRecord?> submit({
    required CreateFactoryPaymentRequest request,
    String? proofPath,
  }) async {
    _isSubmitting = true;
    _submitErrorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      var payload = request;

      if (proofPath != null && proofPath.trim().isNotEmpty) {
        final proofUrl = await _repository.uploadProof(proofPath.trim());
        payload = payload.copyWith(proofUrl: proofUrl);
      }

      final payment = await _repository.createPayment(payload);
      _payments = _sortPayments([payment, ..._payments]);
      _successMessage = payment.status == 'BROUILLON'
          ? 'Brouillon enregistré.'
          : 'Versement enregistré !';
      return payment;
    } on ApiException catch (error) {
      _submitErrorMessage = error.message;
      return null;
    } catch (_) {
      _submitErrorMessage = 'Enregistrement du versement impossible.';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<FactoryPaymentRecord?> updatePayment({
    required String paymentId,
    required CreateFactoryPaymentRequest request,
    String? proofPath,
    String? existingProofUrl,
  }) async {
    _isSubmitting = true;
    _submitErrorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      var payload = request.copyWith(proofUrl: existingProofUrl);

      if (proofPath != null && proofPath.trim().isNotEmpty) {
        final proofUrl = await _repository.uploadProof(proofPath.trim());
        payload = payload.copyWith(proofUrl: proofUrl);
      }

      final updated = await _repository.updatePayment(paymentId, payload);
      _payments = _sortPayments(
        _payments
            .map((payment) => payment.id == paymentId ? updated : payment)
            .toList(growable: false),
      );
      _successMessage = 'Versement mis à jour.';
      return updated;
    } on ApiException catch (error) {
      _submitErrorMessage = error.message;
      return null;
    } catch (_) {
      _submitErrorMessage = 'Mise à jour du versement impossible.';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deletePayment(String paymentId) async {
    _isSubmitting = true;
    _submitErrorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.deletePayment(paymentId);
      _payments = _payments
          .where((payment) => payment.id != paymentId)
          .toList(growable: false);
      _successMessage = 'Versement supprimé.';
      return true;
    } on ApiException catch (error) {
      _submitErrorMessage = error.message;
      return false;
    } catch (_) {
      _submitErrorMessage = 'Suppression du versement impossible.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  List<FactoryPaymentRecord> _sortPayments(
      List<FactoryPaymentRecord> payments) {
    final sorted = List<FactoryPaymentRecord>.from(payments);
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
