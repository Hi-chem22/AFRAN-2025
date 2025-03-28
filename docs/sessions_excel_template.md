# Sessions Import Excel Format

## Structure du fichier Excel

Le fichier Excel doit contenir deux feuilles:

### 1. Feuille "Sessions"

| ID | Session Title | Room | Day | Start Time | End Time | Chairs | Description |
|----|--------------|------|-----|------------|---------|--------|------------|
| 1  | Cérémonie d'ouverture | Grande Salle | 1 | 09:00 | 10:30 | Dr. Jean Dupont, Prof. Marie Curie | Cérémonie d'ouverture du congrès |
| 2  | Innovations médicales | Salle A | 1 | 11:00 | 12:30 | Prof. Albert Einstein | Présentation des dernières innovations |

### 2. Feuille "Subsessions"

| Session ID | Title | Start Time | End Time | Speaker | Speaker Country | Speaker Bio | Speaker Flag | Description |
|------------|-------|------------|---------|---------|----------------|------------|-------------|------------|
| 1 | Discours de bienvenue | 09:00 | 09:15 | Dr. Jean Dupont | France | Docteur en médecine | fr | Introduction au congrès |
| 1 | Présentation des objectifs | 09:15 | 09:45 | Prof. Marie Curie | Pologne | Prix Nobel de physique | pl | Objectifs pour cette année |
| 2 | Avancées en cardiologie | 11:00 | 11:45 | Prof. Albert Einstein | Allemagne | Physicien théoricien | de | Nouvelles approches en cardiologie |

## Notes importantes:

1. L'ID dans la feuille "Sessions" est utilisé pour lier les sous-sessions à leur session principale
2. Les champs obligatoires pour les sessions sont: Session Title, Start Time, End Time
3. Le champ "Chairs" peut contenir plusieurs noms séparés par des virgules
4. Les durées sont calculées automatiquement à partir des heures de début et de fin
5. Si un ID de session existe déjà, la session sera mise à jour au lieu d'être créée

## Format des données:

- **ID**: Identifiant unique pour chaque session (optionnel, généré automatiquement si absent)
- **Session Title**: Titre de la session (obligatoire)
- **Room**: Nom de la salle
- **Day**: Numéro du jour (1, 2, 3, etc.)
- **Start Time**: Heure de début au format HH:MM (obligatoire)
- **End Time**: Heure de fin au format HH:MM (obligatoire)
- **Chairs**: Liste des présidents de séance, séparés par des virgules
- **Speaker**: Nom de l'intervenant
- **Speaker Country**: Pays d'origine de l'intervenant
- **Speaker Flag**: Code du pays (ex: fr, de, us) pour afficher le drapeau

## Postman API Request

```
POST /api/sessions/import HTTP/1.1
Host: localhost:8080
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW

------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="sessions.xlsx"
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

[Contenu binaire du fichier Excel]
------WebKitFormBoundary7MA4YWxkTrZu0gW-- 