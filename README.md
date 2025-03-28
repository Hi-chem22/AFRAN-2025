# AFRAN 2025 - Application du Congrès

Application mobile pour le congrès AFRAN 2025, développée avec Flutter et utilisant une API REST backend connectée à MongoDB Atlas.

## Architecture

L'application est composée de:

- Une application mobile Flutter
- Une API REST Node.js
- Une base de données MongoDB Atlas

## Configuration et exécution

### Application Flutter

1. Installer les dépendances:
   ```bash
   flutter pub get
   ```

2. Exécuter l'application:
   ```bash
   flutter run
   ```

3. Pour le web:
   ```bash
   flutter run -d chrome
   ```

### API REST Backend

1. Installer les dépendances:
   ```bash
   npm install
   ```

2. Lancer le serveur:
   ```bash
   npm run start-backend
   ```

### Variables d'environnement

L'API utilise les variables d'environnement suivantes:

- `PORT`: Port du serveur (par défaut: 3000)
- `MONGODB_URI`: URI de connexion à MongoDB Atlas

## Outils d'administration

### Importation de données

L'outil `admin_import_tool.js` permet d'importer des données JSON dans la base MongoDB via l'API REST.

1. Placer les fichiers JSON dans le dossier `data/` (sessions.json, speakers.json, sponsors.json, partners.json)
2. Exécuter l'outil:
   ```bash
   node admin_import_tool.js
   ```

Options:
- `--api-url=URL`: URL de l'API (défaut: http://localhost:3000)
- `--data-dir=DIR`: Répertoire contenant les fichiers JSON (défaut: ./data)

### Écran de test API

L'application inclut un écran de test pour vérifier la connectivité avec l'API REST:

1. Lancer l'application
2. Aller dans le menu d'administration
3. Sélectionner "Tester l'API REST"

Cet écran permet de:
- Tester la connexion à l'API
- Récupérer les données depuis chaque endpoint
- Visualiser les résultats
- Basculer entre mode en ligne et mode hors ligne

## Structure de la base de données

### Collections

- `sessions`: Sessions et événements du congrès
- `speakers`: Intervenants et présentateurs
- `sponsors`: Sponsors officiels de l'événement
- `partners`: Partenaires institutionnels

## Mode hors ligne

L'application supporte un mode hors ligne qui utilise des données fictives lorsque la connexion à l'API n'est pas disponible. Ce mode peut être configuré dans les paramètres d'administration.

## Contribution

Pour contribuer au projet:

1. Forker le dépôt
2. Créer une branche pour votre fonctionnalité
3. Soumettre une pull request

## Licence

Ce projet est sous licence MIT.

# AFRAN Congress App

AFRAN Congress is a Flutter application designed to manage and display congress sessions, speakers, and related content.

## Key Features

- Session management with chairpersons and subsessions
- Video content linked to sessions
- Speaker profiles and management
- Excel import for bulk session creation

## Excel Import for Sessions

The application supports importing sessions in bulk using an Excel file. This makes it easy to manage large conference programs without having to enter each session manually.

### Excel File Format

The Excel file must contain two sheets:

1. **Sessions** - Contains the main session information
2. **Subsessions** - Contains details of presentations within each session

### Sessions Sheet Columns

| Column | Description | Required |
|--------|-------------|----------|
| ID | Unique identifier for the session | Optional (generated if missing) |
| Session Title | Title of the session | Required |
| Room | Name of the room where the session will take place | Optional |
| Day | Day number (1, 2, 3, etc.) | Optional |
| Start Time | Session start time in format HH:MM | Required |
| End Time | Session end time in format HH:MM | Required |
| Chairs | Names of chairpersons, separated by commas | Optional |
| Description | Session description | Optional |

### Subsessions Sheet Columns

| Column | Description | Required |
|--------|-------------|----------|
| Session ID | ID of the parent session (must match an ID in the Sessions sheet) | Required |
| Title | Title of the subsession/presentation | Required |
| Start Time | Subsession start time in format HH:MM | Optional |
| End Time | Subsession end time in format HH:MM | Optional |
| Speaker | Name of the speaker | Optional |
| Speaker Country | Country of the speaker | Optional |
| Speaker Bio | Biographical information about the speaker | Optional |
| Speaker Flag | ISO country code for flag display (e.g., fr, us) | Optional |
| Description | Subsession description | Optional |

### Importing via API

Use the `/api/sessions/import` endpoint with a multipart form-data request containing the Excel file:

```
POST /api/sessions/import
Content-Type: multipart/form-data

file: [Your Excel file]
```

See the [API documentation](docs/sessions_excel_template.md) for more details.

## Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure the API endpoint in `lib/config/api_config.dart`
4. Run the application with `flutter run`

## Backend Setup

1. Navigate to the `backend-congress` directory
2. Run `npm install` to install dependencies
3. Configure environment variables (see `.env.example`)
4. Start the server with `npm run dev` # AFRAN-2025
# AFRAN-2025
# AFRAN-2025
# AFRAN-2025
# AFRAN-2025
# AFRAN-2025
# AFRAN-2025
# AFRAN-2025
