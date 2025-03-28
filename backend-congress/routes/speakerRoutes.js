const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { 
  addSpeaker, 
  getSpeakers, 
  getSpeakerById,
  getSpeakerFlagImage,
  getSpeakerImage,
  updateSpeaker, 
  deleteSpeaker,
  importSpeakersFromExcel
} = require('../controllers/speakerController');

// Configuration de multer pour l'upload des fichiers
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    // Determine le bon dossier selon le type de fichier
    const uploadDir = file.fieldname === 'imageFlag' 
      ? path.join(__dirname, '../uploads/flags')
      : path.join(__dirname, '../uploads/speakers');
    
    // Créer le dossier s'il n'existe pas
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    // Générer un nom de fichier unique
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, 'speaker-' + uniqueSuffix + ext);
  }
});

// Filter pour limiter les types de fichiers acceptés
const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else if (file.fieldname === 'file' && file.mimetype.includes('spreadsheet') || 
             file.mimetype.includes('excel') ||
             file.originalname.endsWith('.xlsx') ||
             file.originalname.endsWith('.xls')) {
    // Accepter les fichiers Excel
    cb(null, true);
  } else {
    cb(null, false);
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024 // Limite à 10MB
  }
});

// Middleware pour uploader plusieurs types de fichiers
const uploadFields = upload.fields([
  { name: 'imageFlag', maxCount: 1 },
  { name: 'image', maxCount: 1 }
]);

// Configuration pour l'upload des fichiers Excel
const excelStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = path.join(__dirname, '../uploads/temp');
    
    // Créer le dossier s'il n'existe pas
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, 'speakers-import-' + uniqueSuffix + ext);
  }
});

const uploadExcel = multer({
  storage: excelStorage,
  fileFilter: (req, file, cb) => {
    if (file.mimetype.includes('spreadsheet') || 
        file.mimetype.includes('excel') ||
        file.originalname.endsWith('.xlsx') ||
        file.originalname.endsWith('.xls')) {
      cb(null, true);
    } else {
      cb(new Error('Only Excel files are allowed'), false);
    }
  },
  limits: {
    fileSize: 10 * 1024 * 1024 // Limite à 10MB
  }
});

// Routes pour les intervenants
router.post('/', (req, res, next) => {
  // If URLs are provided and it's not multipart/form-data, skip multer
  if ((req.body.flagUrl || req.body.speakerImageUrl) && !req.is('multipart/form-data')) {
    return next();
  }
  // Otherwise, use multer for file uploads
  uploadFields(req, res, (err) => {
    if (err instanceof multer.MulterError) {
      // A Multer error occurred when uploading
      return res.status(400).json({ error: err.message });
    } else if (err) {
      // An unknown error occurred
      return res.status(400).json({ error: err.message });
    }
    // Everything went fine, proceed
    next();
  });
}, addSpeaker);

// Import speakers from Excel
router.post('/import', uploadExcel.single('file'), (req, res) => {
  if (!req.file) {
    console.log('No file uploaded in the import route');
    return res.status(400).json({ message: 'No file uploaded' });
  }
  importSpeakersFromExcel(req, res);
});

router.get('/', getSpeakers);
router.get('/:id', getSpeakerById);
router.get('/:id/flag-image', getSpeakerFlagImage);
router.get('/:id/image', getSpeakerImage);
router.put('/:id', uploadFields, updateSpeaker);
router.delete('/:id', deleteSpeaker);

module.exports = router; 