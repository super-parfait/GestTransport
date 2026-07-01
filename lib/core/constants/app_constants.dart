class AppConstants {
  // API
  static const String baseUrl = 'https://api.yourdomain.com/api/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'current_user';

  // Pagination
  static const int pageSize = 20;

  // Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String currency = 'FCFA';
  static const String currencySymbol = 'F';

  // Payment methods
  static const List<String> paymentMethods = [
    'Espèces',
    'Wave',
    'Orange Money',
    'MTN',
    'Moov',
    'Banque',
    'Chèque',
    'Autre',
  ];

  // Material types
  static const List<String> materialTypes = ['Sable', 'Gravier', 'Transport'];

  // Document types
  static const List<String> documentTypes = [
    'Assurance',
    'Visite technique',
    'Patente'
  ];

  // Truck statuses
  static const Map<String, String> truckStatuses = {
    'active': 'Actif',
    'available': 'Disponible',
    'maintenance': 'En entretien',
    'breakdown': 'En panne',
    'traveling': 'En voyage',
  };

  // Revenue types
  static const List<String> revenueTypes = ['Par voyage', 'Par semaine'];

  // Oil change types
  static const List<String> oilChangeTypes = [
    'Par kilométrage',
    'Par semaines'
  ];

  // Alert thresholds
  static const int documentExpiryWarningDays = 30;
  static const int oilChangeWarningKm = 500;
}

class AppStrings {
  // App
  static const String appName = 'TranspoGest';
  static const String appTagline = 'Gestion Transport & Matériaux';

  // Auth
  static const String register = 'Inscription';
  static const String login = 'Connexion';
  static const String logout = 'Déconnexion';
  static const String fullName = 'Nom complet';
  static const String phone = 'Téléphone';
  static const String email = 'Email';
  static const String role = 'Rôle';
  static const String password = 'Mot de passe';
  static const String confirmPassword = 'Confirmer le mot de passe';
  static const String connecting = 'Connexion en cours...';
  static const String registering = 'Création du compte...';
  static const String loginError =
      'Identifiants incorrects. Veuillez réessayer.';

  static const List<String> registrationRoles = [
    'MANAGER',
    'ACCOUNTANT',
    'DRIVER',
  ];

  static const Map<String, String> registrationRoleLabels = {
    'MANAGER': 'Proprietaire (Manager)',
    'ACCOUNTANT': 'Comptable',
    'DRIVER': 'Chauffeur',
  };

  static const Map<String, String> userRoleLabels = {
    'ADMIN': 'Admin',
    'MANAGER': 'Manager',
    'ACCOUNTANT': 'Comptable',
    'DRIVER': 'Chauffeur',
    'VIEWER': 'Lecture',
  };

  // Navigation
  static const String home = 'Accueil';
  static const String operations = 'Opérations';
  static const String trucks = 'Camions';
  static const String clients = 'Clients';
  static const String reports = 'Rapports';

  // Dashboard
  static const String dailyLoadings = 'Chargements du jour';
  static const String factoryPayments = 'Versements usine';
  static const String clientPayments = 'Règlements clients';
  static const String dailyExpenses = 'Dépenses du jour';
  static const String dailyRevenues = 'Recettes du jour';
  static const String debtorClients = 'Clients débiteurs';
  static const String alertTrucks = 'Camions en alerte';
  static const String expiredDocs = 'Documents expirés';
  static const String importantAlerts = 'Alertes importantes';

  // Operations
  static const String factoryPayment = 'Versement usine';
  static const String clientLoading = 'Chargement client';
  static const String clientPayment = 'Règlement client';
  static const String expenses = 'Charges / Dépenses';
  static const String revenue = 'Recettes';
  static const String sites = 'Sites & usines';

  // Common
  static const String save = 'Enregistrer';
  static const String validate = 'Valider';
  static const String cancel = 'Annuler';
  static const String confirm = 'Confirmer';
  static const String delete = 'Supprimer';
  static const String edit = 'Modifier';
  static const String add = 'Ajouter';
  static const String search = 'Rechercher';
  static const String filter = 'Filtrer';
  static const String export = 'Exporter PDF';
  static const String share = 'Partager';
  static const String viewReport = 'Voir rapport';
  static const String draft = 'Enregistrer brouillon';
  static const String addPhoto = 'Ajouter une photo';
  static const String addLine = '+ Ajouter une ligne';
  static const String required = 'Ce champ est obligatoire';
  static const String loading = 'Chargement...';
  static const String noData = 'Aucune donnée';
  static const String error = 'Une erreur est survenue';
  static const String retry = 'Réessayer';
}
