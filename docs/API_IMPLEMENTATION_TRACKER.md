# Suivi d'Implementation API

Derniere mise a jour: 2026-06-29

Ce fichier sert de reference pour suivre les fonctionnalites deja branchees, celles en cours d'alignement et celles encore a implementer.

## Orientation du projet

- L'application Flutter est la reference prioritaire du produit.
- Les ecrans, les usages metier et les besoins de presentation du mobile pilotent les decisions d'integration.
- Le backend sera aligne progressivement sur les besoins de l'app mobile, y compris si cela implique des ajustements de routes, DTO, champs ou agregations.
- Une fonctionnalite peut donc etre marquee `Partiel` meme si le backend existe deja, tant que le contrat n'est pas encore adapte au mobile.

## Regles de suivi

- `Termine` : la fonctionnalite est branchee dans l'application et exploitable.
- `Partiel` : l'architecture est en place, mais il reste un ecart de schema, de route ou d'ecran.
- `A faire` : non branche ou non commence.

## Infrastructure terminee

- Chargement de l'environnement via `.env`.
- Configuration centralisee via `AppConfig`.
- Client HTTP centralise via `ApiClient`.
- Persistance du token/session via `TokenStorage`.
- Injection des dependances via `AppContainer`.
- Architecture repository + data sources pour `auth`, `dashboard`, `clients` et `trucks`.
- Base de responsivite mobile via `AppBreakpoints` et `ResponsiveContent`.
- Police globale `Ubuntu` appliquee au theme.

## Suivi des fonctionnalites

| Fonctionnalite | Etat | Notes |
| --- | --- | --- |
| Inscription utilisateur | Termine | `POST /auth/register` branche cote Flutter avec creation de session immediate apres inscription. |
| Connexion utilisateur | Termine | `POST /auth/login` branche, session stockee localement, bascule automatique entre ecran de login et application. |
| Restauration de session | Termine | Session relue au demarrage via `SessionController`. |
| Recuperation du profil courant | A faire | L'endpoint backend `GET /auth/me` existe mais n'est pas encore consomme cote Flutter. |
| Tableau de bord accueil | Partiel | Le controller/repository existent, mais le frontend attend `/dashboard/overview` alors que le backend expose surtout `GET /reports/summary` et `GET /alerts`. |
| Liste des clients | Partiel | Le datasource distant appelle `GET /clients`, mais le modele Flutter attend encore des champs de presentation non exposes tels quels par le DTO backend. |
| Details client / releve client | A faire | Le backend expose `GET /clients/:id` et `GET /reports/clients/:clientId`, mais ce flux n'est pas encore branche proprement dans l'app. |
| Liste des camions | Partiel | Le datasource distant appelle `GET /trucks`, mais le modele Flutter attend encore `plate`, `driver`, `km`, `alerts`, documents et historiques non alignes sur le DTO backend actuel. |
| Details camion / releve camion | A faire | Le backend expose `GET /trucks/:id` et `GET /reports/trucks/:truckId`, integration Flutter non faite. |
| Chargements | A faire | Backend disponible sur `/loadings`, ecrans Flutter encore non relies a l'API. |
| Charges | A faire | Backend disponible sur `/charges`, ecrans Flutter encore non relies a l'API. |
| Recettes | A faire | Backend disponible sur `/revenues`, ecrans Flutter encore non relies a l'API. |
| Paiements clients | A faire | Backend disponible sur `/client-payments`, integration Flutter a faire. |
| Paiements usines | A faire | Backend disponible sur `/factory-payments`, integration Flutter a faire. |
| Vidanges | A faire | Backend disponible sur `/oil-changes`, integration Flutter a faire. |
| Documents camions | A faire | Backend disponible sur `/truck-documents`, integration Flutter a faire. |
| Alertes | A faire | Backend disponible sur `/alerts`, a integrer dans l'accueil et les ecrans camion. |
| Rapports | A faire | Backend disponible sur `/reports`, ecran Flutter present mais non connecte. |

## Roadmap des pages a implementer

L'objectif est d'avancer page par page avec un resultat visible rapidement dans l'application, afin de valider l'UX, les donnees et le contrat backend au fur et a mesure.

| Ordre | Page | Priorite | Objectif visible | Source API cible | Test visible attendu |
| --- | --- | --- | --- | --- | --- |
| 1 | Inscription | Haute | Creer un compte reel et entrer dans l'application | `POST /auth/register` | Renseigner le formulaire puis arriver sur l'accueil sans mock |
| 2 | Login | Haute | Connexion reelle et entree dans l'application | `POST /auth/login`, `GET /auth/me` | Se connecter avec un vrai utilisateur et arriver sur l'accueil sans mock |
| 3 | Accueil / Dashboard | Haute | Afficher les chiffres reels et les alertes | `GET /reports/summary`, `GET /alerts` ou endpoint agrege dedie | Voir les cartes de synthese remplies avec des donnees backend |
| 4 | Liste des clients | Haute | Voir la liste reelle des clients | `GET /clients` | La page clients charge, liste les clients, gere loading et erreur |
| 5 | Detail client | Haute | Voir le solde, l'historique et le releve du client | `GET /clients/:id`, `GET /reports/clients/:clientId` | Ouvrir un client et verifier les informations sans donnees fictives |
| 6 | Liste des camions | Haute | Voir la flotte reelle | `GET /trucks` | La page camions affiche les camions backend avec statut lisible |
| 7 | Detail camion | Haute | Voir etat, kilometrage, documents et historique camion | `GET /trucks/:id`, `GET /reports/trucks/:truckId` | Ouvrir un camion et voir ses informations principales |
| 8 | Operations / Chargements | Haute | Enregistrer et consulter les chargements | `GET /loadings`, `POST /loadings` | Creer un chargement puis le voir apparaitre dans la liste |
| 9 | Charges | Moyenne | Consulter et saisir les depenses | `GET /charges`, `POST /charges` | Ajouter une charge et verifier sa presence immediate |
| 10 | Recettes | Moyenne | Consulter les revenus reels | `GET /revenues`, `POST /revenues` | Voir une liste de recettes coherente et mise a jour |
| 11 | Paiements clients | Moyenne | Enregistrer les reglements clients | `GET /client-payments`, `POST /client-payments` | Creer un paiement et voir le solde client evoluer |
| 12 | Paiements usines | Moyenne | Suivre les paiements vers les fournisseurs/usines | `GET /factory-payments`, `POST /factory-payments` | Ajouter un paiement usine et le voir dans l'historique |
| 13 | Vidanges | Moyenne | Suivre l'entretien periodique des camions | `GET /oil-changes`, `POST /oil-changes` | Ajouter une vidange et voir l'alerte ou l'historique associe |
| 14 | Documents camions | Moyenne | Gerer assurances, visites, patente et pieces jointes | `GET /truck-documents`, `POST /truck-documents` | Voir les documents d'un camion et leur etat d'expiration |
| 15 | Rapports | Moyenne | Consulter les releves et syntheses metier | `GET /reports/summary`, `GET /reports/clients/:clientId`, `GET /reports/trucks/:truckId` | Ouvrir le module rapports et filtrer une periode valide |

## Lots recommandes pour une visibilite rapide

### Lot 1 - Parcours minimum visible

- Login
- Inscription
- Accueil / Dashboard
- Liste des clients
- Liste des camions

Resultat attendu :

- l'application devient presentable avec de vraies donnees sur les ecrans principaux
- on valide la connexion, la navigation et les premiers contrats backend

### Lot 2 - Lecture detaillee metier

- Detail client
- Detail camion
- Alertes
- Rapports de consultation

Resultat attendu :

- on peut ouvrir une fiche metier et verifier les informations critiques
- les besoins d'agregation backend deviennent clairs

### Lot 3 - Saisie operationnelle

- Chargements
- Charges
- Recettes
- Paiements clients
- Paiements usines

Resultat attendu :

- l'application commence a couvrir le flux metier quotidien
- chaque creation doit etre testee par une verification visuelle immediate dans la liste concernee

### Lot 4 - Maintenance et conformite

- Vidanges
- Documents camions

Resultat attendu :

- on couvre la partie entretien et administratif des camions
- les alertes documentaires et de maintenance deviennent testables visuellement

## Endpoints backend deja identifies

Base URL attendue dans l'application :

- `http://<host>:3000/api/v1`

Routes utiles deja presentes dans le backend :

- `POST /auth/login`
- `GET /auth/me`
- `GET /clients`
- `GET /clients/:id`
- `GET /trucks`
- `GET /trucks/:id`
- `GET /loadings`
- `GET /charges`
- `GET /revenues`
- `GET /client-payments`
- `GET /factory-payments`
- `GET /oil-changes`
- `GET /truck-documents`
- `GET /alerts`
- `GET /reports/summary`
- `GET /reports/clients/:clientId`
- `GET /reports/trucks/:truckId`

## Ecarts techniques deja identifies

- Le backend devra exposer un equivalent propre a `dashboardOverview` ou une composition d'endpoints adaptee a l'accueil mobile.
- Le contrat backend `clients` devra etre aligne sur les besoins du `ClientModel` mobile, ou le modele mobile devra etre refactorise de maniere controlee si le choix produit change.
- Le contrat backend `trucks` devra etre aligne sur les besoins du `TruckModel` mobile, notamment pour les informations de presentation, d'etat et d'historique.
- Plusieurs vues mobiles attendent des donnees agregees; si elles ne sont pas disponibles telles quelles, le backend devra fournir les endpoints ou enrichissements necessaires.

## Ordre recommande pour la suite

1. Stabiliser le contrat cible cote application Flutter pour `dashboard`, `clients` et `trucks`.
2. Aligner le backend sur ce contrat mobile prioritaire.
3. Brancher ensuite les listes et details en lecture seule dans l'app.
4. Integrer les ecritures metier : chargements, charges, paiements, recettes.
5. Terminer par les rapports, alertes et documents.
