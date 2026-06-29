class DashboardAlert {
  final String type;
  final String message;
  final String time;

  const DashboardAlert({
    required this.type,
    required this.message,
    required this.time,
  });

  factory DashboardAlert.fromJson(Map<String, dynamic> json) {
    return DashboardAlert(
      type: (json['type'] ?? 'info').toString(),
      message: (json['message'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'time': time,
    };
  }
}

class DashboardOverview {
  final int dailyLoadings;
  final String factoryPayments;
  final String clientPayments;
  final String dailyExpenses;
  final String dailyRevenues;
  final int debtorClients;
  final int alertTrucks;
  final int expiredDocs;
  final List<DashboardAlert> alerts;

  const DashboardOverview({
    required this.dailyLoadings,
    required this.factoryPayments,
    required this.clientPayments,
    required this.dailyExpenses,
    required this.dailyRevenues,
    required this.debtorClients,
    required this.alertTrucks,
    required this.expiredDocs,
    required this.alerts,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      dailyLoadings: _asInt(json['daily_loadings'] ?? json['dailyLoadings']),
      factoryPayments: _asString(
        json['factory_payments'] ?? json['factoryPayments'],
      ),
      clientPayments: _asString(
        json['client_payments'] ?? json['clientPayments'],
      ),
      dailyExpenses: _asString(
        json['daily_expenses'] ?? json['dailyExpenses'],
      ),
      dailyRevenues: _asString(
        json['daily_revenues'] ?? json['dailyRevenues'],
      ),
      debtorClients: _asInt(json['debtor_clients'] ?? json['debtorClients']),
      alertTrucks: _asInt(json['alert_trucks'] ?? json['alertTrucks']),
      expiredDocs: _asInt(json['expired_docs'] ?? json['expiredDocs']),
      alerts: _parseAlerts(json['alerts']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'daily_loadings': dailyLoadings,
      'factory_payments': factoryPayments,
      'client_payments': clientPayments,
      'daily_expenses': dailyExpenses,
      'daily_revenues': dailyRevenues,
      'debtor_clients': debtorClients,
      'alert_trucks': alertTrucks,
      'expired_docs': expiredDocs,
      'alerts': alerts.map((alert) => alert.toJson()).toList(),
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _asString(dynamic value) => value?.toString() ?? '0';

  static List<DashboardAlert> _parseAlerts(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) => DashboardAlert.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
