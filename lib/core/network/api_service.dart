// ─── Local Data Service (aucune API requise) ──────────────────────────────────
// Toutes les données sont statiques et disponibles sans connexion réseau.

class AppData {
  // ── Dashboard ─────────────────────────────────────────────────────────────
  static Map<String, dynamic> get dashboard => {
        'daily_loadings': 12,
        'factory_payments': '2 500 000',
        'client_payments': '1 800 000',
        'daily_expenses': '450 000',
        'daily_revenues': '3 200 000',
        'debtor_clients': 8,
        'alert_trucks': 3,
        'expired_docs': 2,
        'alerts': [
          {
            'type': 'error',
            'message': 'Assurance expirée — Camion CI-1234-AB',
            'time': 'Il y a 2 jours'
          },
          {
            'type': 'warning',
            'message': 'Vidange bientôt — Camion CI-5678-CD (450 km restants)',
            'time': 'Aujourd\'hui'
          },
          {
            'type': 'error',
            'message': 'Visite technique expirée — Camion CI-9012-EF',
            'time': 'Il y a 5 jours'
          },
          {
            'type': 'warning',
            'message':
                'Client KOUAME Eric — Solde débiteur élevé : 4 500 000 F',
            'time': 'Aujourd\'hui'
          },
        ],
      };

  // ── Camions ───────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> get trucks => [
        {
          'id': '1',
          'plate': 'CI-1234-AB',
          'driver': 'KONAN Yao',
          'phone': '07 11 22 33 44',
          'status': 'active',
          'km': 125430,
          'alerts': ['assurance_expired'],
          'assurance_expiry': '15/03/2026',
          'visite_expiry': '20/08/2025',
          'patente_expiry': '31/12/2025',
          'loadings': [
            {
              'date': '27/06/2025',
              'client': 'KOUAME Eric',
              'type': 'Sable',
              'quantity': '15 m³',
              'montant': '225 000 F'
            },
            {
              'date': '26/06/2025',
              'client': 'BTP SERVICES',
              'type': 'Gravier',
              'quantity': '12 m³',
              'montant': '216 000 F'
            },
            {
              'date': '25/06/2025',
              'client': 'TOURE Construction',
              'type': 'Sable',
              'quantity': '18 m³',
              'montant': '270 000 F'
            },
          ],
          'expenses': [
            {'date': '20/06/2025', 'type': 'Carburant', 'montant': '85 000 F'},
            {
              'date': '15/06/2025',
              'type': 'Réparation pneu',
              'montant': '45 000 F'
            },
          ],
          'maintenances': [
            {
              'date': '10/06/2025',
              'type': 'Entretien général',
              'montant': '120 000 F',
              'garage': 'Garage YAPI'
            },
          ],
          'oil_changes': [
            {
              'date': '01/05/2025',
              'km': 123000,
              'type': 'Par km',
              'prochain_km': 128000,
              'huile': '15W-40',
              'filtre': true
            },
          ],
          'revenues': [
            {
              'date': '27/06/2025',
              'client': 'KOUAME Eric',
              'voyages': 3,
              'montant': '675 000 F'
            },
            {
              'date': '26/06/2025',
              'client': 'BTP SERVICES',
              'voyages': 2,
              'montant': '432 000 F'
            },
          ],
        },
        {
          'id': '2',
          'plate': 'CI-5678-CD',
          'driver': 'OUATTARA Issa',
          'phone': '05 22 33 44 55',
          'status': 'traveling',
          'km': 89250,
          'alerts': ['oil_change_soon'],
          'assurance_expiry': '30/09/2025',
          'visite_expiry': '15/07/2025',
          'patente_expiry': '31/12/2025',
          'loadings': [
            {
              'date': '27/06/2025',
              'client': 'DIALLO Travaux',
              'type': 'Transport',
              'quantity': '1 voyage',
              'montant': '150 000 F'
            },
          ],
          'expenses': [
            {'date': '22/06/2025', 'type': 'Carburant', 'montant': '72 000 F'},
          ],
          'maintenances': [],
          'oil_changes': [
            {
              'date': '15/04/2025',
              'km': 87000,
              'type': 'Par km',
              'prochain_km': 92000,
              'huile': '10W-40',
              'filtre': false
            },
          ],
          'revenues': [
            {
              'date': '27/06/2025',
              'client': 'DIALLO Travaux',
              'voyages': 1,
              'montant': '150 000 F'
            },
          ],
        },
        {
          'id': '3',
          'plate': 'CI-9012-EF',
          'driver': 'BAMBA Mamadou',
          'phone': '01 33 44 55 66',
          'status': 'maintenance',
          'km': 204100,
          'alerts': ['visite_expired'],
          'assurance_expiry': '28/06/2025',
          'visite_expiry': '10/05/2025',
          'patente_expiry': '31/12/2025',
          'loadings': [],
          'expenses': [
            {
              'date': '25/06/2025',
              'type': 'Réparation moteur',
              'montant': '380 000 F'
            },
            {
              'date': '18/06/2025',
              'type': 'Pièces de rechange',
              'montant': '95 000 F'
            },
          ],
          'maintenances': [
            {
              'date': '24/06/2025',
              'type': 'Révision moteur',
              'montant': '380 000 F',
              'garage': 'Garage ATTICHY'
            },
            {
              'date': '05/05/2025',
              'type': 'Entretien général',
              'montant': '145 000 F',
              'garage': 'Garage YAPI'
            },
          ],
          'oil_changes': [
            {
              'date': '01/03/2025',
              'km': 201000,
              'type': 'Par semaines',
              'prochaine_date': '01/09/2025',
              'huile': '20W-50',
              'filtre': true
            },
          ],
          'revenues': [],
        },
        {
          'id': '4',
          'plate': 'CI-3456-GH',
          'driver': 'COULIBALY Drissa',
          'phone': '07 44 55 66 77',
          'status': 'available',
          'km': 67800,
          'alerts': [],
          'assurance_expiry': '31/10/2025',
          'visite_expiry': '20/11/2025',
          'patente_expiry': '31/12/2025',
          'loadings': [
            {
              'date': '26/06/2025',
              'client': 'ENTREPRISE GNAGNE',
              'type': 'Gravier',
              'quantity': '20 m³',
              'montant': '360 000 F'
            },
            {
              'date': '25/06/2025',
              'client': 'ENTREPRISE GNAGNE',
              'type': 'Gravier',
              'quantity': '20 m³',
              'montant': '360 000 F'
            },
          ],
          'expenses': [
            {'date': '20/06/2025', 'type': 'Carburant', 'montant': '65 000 F'},
          ],
          'maintenances': [],
          'oil_changes': [],
          'revenues': [
            {
              'date': '26/06/2025',
              'client': 'ENTREPRISE GNAGNE',
              'voyages': 4,
              'montant': '720 000 F'
            },
          ],
        },
        {
          'id': '5',
          'plate': 'CI-7890-IJ',
          'driver': 'KONE Seydou',
          'phone': '05 55 66 77 88',
          'status': 'breakdown',
          'km': 178900,
          'alerts': ['breakdown'],
          'assurance_expiry': '15/08/2025',
          'visite_expiry': '30/07/2025',
          'patente_expiry': '31/12/2025',
          'loadings': [],
          'expenses': [
            {
              'date': '27/06/2025',
              'type': 'Dépannage route',
              'montant': '55 000 F'
            },
          ],
          'maintenances': [],
          'oil_changes': [],
          'revenues': [],
        },
      ];

  // ── Clients ───────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> get clients => [
        {
          'id': '1',
          'name': 'KOUAME Eric',
          'phone': '07 00 11 22 33',
          'address': 'Cocody, Abidjan',
          'balance': 4500000.0,
          'total_credit': 12500000.0,
          'total_paid': 8000000.0,
          'loadings': [
            {
              'date': '27/06/2025',
              'camion': 'CI-1234-AB',
              'type': 'Sable',
              'quantity': '15 m³',
              'montant': 225000.0
            },
            {
              'date': '20/06/2025',
              'camion': 'CI-1234-AB',
              'type': 'Gravier',
              'quantity': '10 m³',
              'montant': 180000.0
            },
            {
              'date': '15/06/2025',
              'camion': 'CI-3456-GH',
              'type': 'Sable',
              'quantity': '20 m³',
              'montant': 300000.0
            },
          ],
          'payments': [
            {'date': '25/06/2025', 'montant': 500000.0, 'mode': 'Espèces'},
            {'date': '10/06/2025', 'montant': 1000000.0, 'mode': 'Virement'},
          ],
        },
        {
          'id': '2',
          'name': 'BTP SERVICES SARL',
          'phone': '05 00 44 55 66',
          'address': 'Plateau, Abidjan',
          'balance': 1200000.0,
          'total_credit': 5800000.0,
          'total_paid': 4600000.0,
          'loadings': [
            {
              'date': '26/06/2025',
              'camion': 'CI-5678-CD',
              'type': 'Gravier',
              'quantity': '12 m³',
              'montant': 216000.0
            },
            {
              'date': '18/06/2025',
              'camion': 'CI-1234-AB',
              'type': 'Sable',
              'quantity': '15 m³',
              'montant': 225000.0
            },
          ],
          'payments': [
            {'date': '22/06/2025', 'montant': 800000.0, 'mode': 'Chèque'},
          ],
        },
        {
          'id': '3',
          'name': 'TOURE Construction',
          'phone': '01 00 77 88 99',
          'address': 'Marcory, Abidjan',
          'balance': 0.0,
          'total_credit': 3200000.0,
          'total_paid': 3200000.0,
          'loadings': [
            {
              'date': '25/06/2025',
              'camion': 'CI-1234-AB',
              'type': 'Sable',
              'quantity': '18 m³',
              'montant': 270000.0
            },
          ],
          'payments': [
            {'date': '26/06/2025', 'montant': 270000.0, 'mode': 'Espèces'},
          ],
        },
        {
          'id': '4',
          'name': 'DIALLO Travaux',
          'phone': '07 55 66 77 88',
          'address': 'Yopougon, Abidjan',
          'balance': 850000.0,
          'total_credit': 2100000.0,
          'total_paid': 1250000.0,
          'loadings': [
            {
              'date': '27/06/2025',
              'camion': 'CI-5678-CD',
              'type': 'Transport',
              'quantity': '1 voyage',
              'montant': 150000.0
            },
            {
              'date': '20/06/2025',
              'camion': 'CI-5678-CD',
              'type': 'Gravier',
              'quantity': '8 m³',
              'montant': 144000.0
            },
          ],
          'payments': [
            {'date': '21/06/2025', 'montant': 200000.0, 'mode': 'Espèces'},
          ],
        },
        {
          'id': '5',
          'name': 'ENTREPRISE GNAGNE',
          'phone': '05 88 99 00 11',
          'address': 'Abobo, Abidjan',
          'balance': 6200000.0,
          'total_credit': 14000000.0,
          'total_paid': 7800000.0,
          'loadings': [
            {
              'date': '26/06/2025',
              'camion': 'CI-3456-GH',
              'type': 'Gravier',
              'quantity': '20 m³',
              'montant': 360000.0
            },
            {
              'date': '25/06/2025',
              'camion': 'CI-3456-GH',
              'type': 'Gravier',
              'quantity': '20 m³',
              'montant': 360000.0
            },
            {
              'date': '24/06/2025',
              'camion': 'CI-3456-GH',
              'type': 'Sable',
              'quantity': '15 m³',
              'montant': 225000.0
            },
          ],
          'payments': [
            {'date': '20/06/2025', 'montant': 1500000.0, 'mode': 'Virement'},
            {'date': '05/06/2025', 'montant': 2000000.0, 'mode': 'Chèque'},
          ],
        },
      ];

  // ── Historique opérations (rapports) ─────────────────────────────────────
  static List<Map<String, dynamic>> get recentOperations => [
        {
          'date': '27/06/2025',
          'type': 'Chargement',
          'description': 'Sable 15m³ — KOUAME Eric',
          'montant': '+225 000 F',
          'color': 'info'
        },
        {
          'date': '27/06/2025',
          'type': 'Règlement',
          'description': 'DIALLO Travaux — Acompte',
          'montant': '+200 000 F',
          'color': 'success'
        },
        {
          'date': '26/06/2025',
          'type': 'Dépense',
          'description': 'Carburant CI-3456-GH',
          'montant': '-65 000 F',
          'color': 'error'
        },
        {
          'date': '26/06/2025',
          'type': 'Versement',
          'description': 'Carrière du Banco — Livraison 26/06',
          'montant': '-380 000 F',
          'color': 'warning'
        },
        {
          'date': '25/06/2025',
          'type': 'Chargement',
          'description': 'Gravier 20m³ — ENTREPRISE GNAGNE',
          'montant': '+360 000 F',
          'color': 'info'
        },
        {
          'date': '25/06/2025',
          'type': 'Entretien',
          'description': 'Révision CI-9012-EF — Garage ATTICHY',
          'montant': '-380 000 F',
          'color': 'warning'
        },
        {
          'date': '24/06/2025',
          'type': 'Recette',
          'description': 'CI-3456-GH — Semaine 25',
          'montant': '+1 080 000 F',
          'color': 'success'
        },
      ];

  // ── Statistiques hebdo (rapports) ────────────────────────────────────────
  static Map<String, dynamic> get weeklyStats => {
        'total_loadings': 58,
        'total_revenues': '15 840 000',
        'total_expenses': '2 180 000',
        'total_factory': '9 500 000',
        'total_client_payments': '5 700 000',
        'net_balance': '4 160 000',
        'by_type': {
          'Sable': 24,
          'Gravier': 22,
          'Transport': 12,
        },
      };

  // ── Helpers ───────────────────────────────────────────────────────────────
  static Map<String, dynamic>? truckById(String id) => trucks
      .cast<Map<String, dynamic>?>()
      .firstWhere((t) => t!['id'] == id, orElse: () => null);

  static Map<String, dynamic>? clientById(String id) => clients
      .cast<Map<String, dynamic>?>()
      .firstWhere((c) => c!['id'] == id, orElse: () => null);

  static String fmtMoney(double v) {
    if (v >= 1000000)
      return '${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 2)} M F';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)} k F';
    return '${v.toStringAsFixed(0)} F';
  }

  static String fmtMoneyFull(double v) {
    final n = v.toInt();
    return '${n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} F';
  }

  // Statuts camions
  static const truckStatusLabels = {
    'active': 'En service',
    'traveling': 'En route',
    'available': 'Disponible',
    'maintenance': 'En entretien',
    'breakdown': 'En panne',
  };
}
