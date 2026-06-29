# TranspoGest — Application Flutter

Application mobile de gestion Transport & Matériaux BTP (Sable, Gravier, Transport, Camions, Clients, Finances).

---

## 🚀 Démarrage rapide

### Prérequis
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- Android Studio / Xcode / VS Code

### Installation

```bash
cd sand_gravel_app
flutter pub get
flutter run
```

---

## 📁 Architecture du projet

```
lib/
├── main.dart                         # Point d'entrée
├── core/
│   ├── theme/app_theme.dart          # Thème global, couleurs, typographie
│   ├── constants/app_constants.dart  # Constantes, chaînes de texte
│   ├── network/api_service.dart      # Service API (Dio + JWT) + MockData
│   └── widgets/app_widgets.dart      # Composants UI réutilisables
└── features/
    ├── auth/presentation/            # Écran de connexion
    ├── dashboard/presentation/       # Tableau de bord
    ├── main_scaffold.dart            # Navigation principale (bottom nav)
    ├── operations_screen.dart        # Menu opérations
    ├── loadings/presentation/        # Chargement client (Sable/Gravier/Transport)
    ├── factory_payments/presentation/ # Versement usine
    ├── client_payments/presentation/  # Règlement client
    ├── charges/presentation/          # Dépenses (simple + entretien)
    ├── trucks/presentation/           # Liste camions + fiche détail
    │   ├── oil_change_screen.dart    # Vidanges
    │   └── truck_documents_screen.dart # Documents (assurance, visite, patente)
    ├── clients/presentation/          # Liste clients + fiche détail
    ├── revenues/presentation/         # Recettes (par voyage / par semaine)
    └── reports/presentation/          # Rapports et exports
```

---

## 🧩 Composants UI réutilisables (`core/widgets/app_widgets.dart`)

| Composant | Description |
|---|---|
| `AppButton` | Bouton avec 5 variantes (primary, secondary, outlined, danger, ghost) |
| `AppTextField` | Champ texte avec label, validation, préfixe/suffixe |
| `AppMoneyField` | Champ numérique pour montants en FCFA |
| `AppDropdown<T>` | Dropdown stylisé avec label |
| `AppDatePicker` | Sélecteur de date avec calendrier |
| `AppSectionCard` | Carte de section avec titre et icône |
| `AppSummaryCard` | Carte de résumé avec lignes colorées |
| `AppSummaryRow` | Ligne label/valeur pour les résumés |
| `AppStatusBadge` | Badge de statut (success/warning/error/info) |
| `AppFilePicker` | Sélecteur de fichier / photo |
| `AppLoadingOverlay` | Overlay de chargement animé |
| `AppEmptyState` | État vide avec icône et action |
| `AppConfirmDialog` | Dialog de confirmation avec résumé |
| `DashboardMetricCard` | Carte métrique pour le tableau de bord |
| `QuickActionButton` | Bouton action rapide (dashboard) |

---

## 🎨 Système de couleurs

```dart
AppColors.primary        // Vert foncé #1B5E20 — Validation, Finance
AppColors.accent         // Orange #FF6F00 — Alertes
AppColors.error          // Rouge #C62828 — Urgences
AppColors.info           // Bleu #0D47A1 — Information
AppColors.disabled       // Gris clair — Champs désactivés
AppColors.success        // Vert succès
AppColors.warning        // Orange urgence
```

---

## 🔐 Authentification JWT

Le service API (`ApiService`) gère :
- Ajout automatique du token Bearer dans les headers
- Refresh automatique du token en cas d'expiration (401)
- Stockage sécurisé avec `flutter_secure_storage`

### Connexion à votre API NestJS

Mettez à jour `AppConstants.baseUrl` :
```dart
static const String baseUrl = 'https://votre-api.com/api/v1';
```

---

## 📱 Écrans implémentés

1. ✅ **Connexion** — Login sécurisé avec animation
2. ✅ **Dashboard** — Métriques, alertes, raccourcis
3. ✅ **Navigation** — Bottom nav 5 onglets
4. ✅ **Opérations** — Menu central
5. ✅ **Versement usine** — Formulaire complet 4 sections
6. ✅ **Chargement client** — Sélecteur Sable/Gravier/Transport, calcul auto
7. ✅ **Règlement client** — Solde auto, reste à payer calculé
8. ✅ **Charges/Dépenses** — Entretien garage (lignes dynamiques) + Dépense simple
9. ✅ **Camions** — Liste avec badges de statut et alertes
10. ✅ **Fiche camion** — Onglets : Résumé, Chargements, Dépenses, Entretiens, Vidanges, Documents, Recettes
11. ✅ **Vidanges** — Par kilométrage ou par semaines, avec historique
12. ✅ **Documents camion** — Assurance, Visite, Patente avec statut automatique
13. ✅ **Recettes** — Par voyage ou par semaine, dépenses liées
14. ✅ **Clients** — Liste avec soldes colorés, recherche
15. ✅ **Fiche client** — Onglets avec résumé financier
16. ✅ **Rapports** — Sélecteur de type, filtres, aperçu, export PDF

---

## 🔗 Connexion à l'API REST NestJS

Pour chaque feature, remplacez les données mock par des appels API réels :

```dart
// Exemple : charger la liste des clients
final response = await ApiService.get('/clients');
final clients = (response.data['data'] as List)
    .map((c) => Client.fromJson(c))
    .toList();
```

---

## 📦 Dépendances principales

```yaml
flutter_riverpod: ^2.4.0    # State management
go_router: ^12.0.0          # Navigation
dio: ^5.3.0                 # HTTP / API
flutter_secure_storage: ^9.0.0  # Stockage JWT
google_fonts: ^6.1.0        # Typographie Inter
intl: ^0.18.1               # Formatage dates/nombres
image_picker: ^1.0.4        # Sélection photos
```
