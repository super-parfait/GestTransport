import 'package:flutter_test/flutter_test.dart';

import 'package:sand_gravel_app/features/dashboard/data/models/dashboard_overview.dart';

void main() {
  test('parses the current dashboard overview contract', () {
    final overview = DashboardOverview.fromJson({
      'role': 'ADMIN',
      'daily_loadings': 4,
      'factory_payments': '2 500 000',
      'client_payments': '1 800 000',
      'daily_expenses': '445 000',
      'daily_revenues': '590 000',
      'debtor_clients': 4,
      'alert_trucks': 2,
      'expired_docs': 2,
      'alerts': [
        {
          'type': 'error',
          'message': 'Assurance expirée',
          'time': 'Il y a 1 jour',
        },
      ],
    });

    expect(overview.role, 'ADMIN');
    expect(overview.dailyLoadings, 4);
    expect(overview.factoryPaymentsAmount, 2500000);
    expect(overview.clientPaymentsAmount, 1800000);
    expect(overview.dailyExpensesAmount, 445000);
    expect(overview.dailyRevenuesAmount, 590000);
    expect(overview.totalInflowAmount, 2390000);
    expect(overview.totalOutflowAmount, 2945000);
    expect(overview.estimatedNetAmount, -555000);
    expect(overview.hasAlerts, isTrue);
    expect(overview.alerts, hasLength(1));
  });

  test('keeps amount parsing stable with formatted strings', () {
    final overview = DashboardOverview.fromJson({
      'factoryPayments': '90 000 F',
      'clientPayments': '150 000 FCFA',
      'dailyExpenses': '12 500',
      'dailyRevenues': '300000',
      'dailyLoadings': '3',
      'debtorClients': '1',
      'alertTrucks': '0',
      'expiredDocs': '0',
      'alerts': const [],
    });

    expect(overview.factoryPaymentsAmount, 90000);
    expect(overview.clientPaymentsAmount, 150000);
    expect(overview.dailyExpensesAmount, 12500);
    expect(overview.dailyRevenuesAmount, 300000);
    expect(overview.estimatedNetAmount, 347500);
    expect(overview.hasAlerts, isFalse);
  });
}
