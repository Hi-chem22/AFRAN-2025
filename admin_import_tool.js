const fs = require('fs');
const path = require('path');
const axios = require('axios');
const { promisify } = require('util');

// Configuration
const API_URL = process.env.API_URL || 'http://localhost:3000';
const DATA_DIR = process.env.DATA_DIR || './data';
const readFileAsync = promisify(fs.readFile);
const readdirAsync = promisify(fs.readdir);

// Collections à importer
const COLLECTIONS = ['sessions', 'speakers', 'sponsors', 'partners'];

/**
 * Fonction principale
 */
async function importData() {
  console.log('=== AFRAN 2025 - Outil d\'importation de données ===');
  console.log(`URL de l'API: ${API_URL}`);
  console.log(`Dossier de données: ${DATA_DIR}`);
  console.log('------------------------------------------------');
  
  try {
    // Vérifier si l'API est accessible
    console.log('Vérification de la connexion à l\'API...');
    const apiCheck = await checkApiConnection();
    if (!apiCheck) {
      console.error('Impossible de se connecter à l\'API. Vérifiez que le serveur est en cours d\'exécution.');
      process.exit(1);
    }
    console.log('Connexion à l\'API établie avec succès.\n');
    
    // Vérifier si le dossier de données existe
    if (!fs.existsSync(DATA_DIR)) {
      console.error(`Le dossier de données "${DATA_DIR}" n'existe pas.`);
      process.exit(1);
    }
    
    // Importer chaque collection
    for (const collection of COLLECTIONS) {
      await importCollection(collection);
    }
    
    console.log('\nImportation terminée avec succès!');
  } catch (error) {
    console.error('Erreur lors de l\'importation des données:', error.message);
    process.exit(1);
  }
}

/**
 * Vérifier la connexion à l'API
 */
async function checkApiConnection() {
  try {
    const response = await axios.get(API_URL);
    return response.status === 200;
  } catch (error) {
    return false;
  }
}

/**
 * Importer une collection
 */
async function importCollection(collection) {
  const filePath = path.join(DATA_DIR, `${collection}.json`);
  
  // Vérifier si le fichier existe
  if (!fs.existsSync(filePath)) {
    console.warn(`Fichier ${filePath} introuvable. Collection "${collection}" ignorée.`);
    return;
  }
  
  try {
    console.log(`Importation de la collection "${collection}"...`);
    
    // Lire et parser le fichier JSON
    const fileContent = await readFileAsync(filePath, 'utf8');
    const data = JSON.parse(fileContent);
    
    if (!Array.isArray(data)) {
      console.error(`Le fichier ${filePath} ne contient pas un tableau JSON valide.`);
      return;
    }
    
    console.log(`- ${data.length} éléments trouvés`);
    
    // Envoyer les données à l'API
    const response = await axios.post(`${API_URL}/admin/import`, {
      collection,
      data
    });
    
    console.log(`- Importation réussie: ${response.data.message || JSON.stringify(response.data)}`);
    
  } catch (error) {
    console.error(`Erreur lors de l'importation de la collection "${collection}":`, error.message);
  }
}

/**
 * Afficher une aide
 */
function showHelp() {
  console.log(`
Usage: node admin_import_tool.js [options]

Options:
  --api-url=URL    URL de l'API (défaut: http://localhost:3000)
  --data-dir=DIR   Dossier contenant les fichiers de données (défaut: ./data)
  --help           Afficher cette aide

Exemple:
  node admin_import_tool.js --api-url=http://localhost:3000 --data-dir=./my-data
  `);
}

/**
 * Analyser les arguments de ligne de commande
 */
function parseArgs() {
  const args = process.argv.slice(2);
  
  for (const arg of args) {
    if (arg === '--help' || arg === '-h') {
      showHelp();
      process.exit(0);
    }
    
    if (arg.startsWith('--api-url=')) {
      process.env.API_URL = arg.split('=')[1];
    }
    
    if (arg.startsWith('--data-dir=')) {
      process.env.DATA_DIR = arg.split('=')[1];
    }
  }
}

// Exécuter le script
parseArgs();
importData().catch(error => {
  console.error('Erreur non gérée:', error);
  process.exit(1);
}); 