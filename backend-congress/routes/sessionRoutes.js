const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { 
  addSession, 
  getSessions, 
  getSessionById, 
  getSessionsByDayAndRoom,
  updateSession, 
  deleteSession,
  updateSessionChairpersons,
  importSessionsFromExcel
} = require('../controllers/sessionController');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Ensure uploads directory exists
    const uploadsDir = path.join(__dirname, '../uploads');
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }
    console.log('Upload destination:', uploadsDir);
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now();
    const filename = file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname);
    console.log('Generated filename:', filename);
    cb(null, filename);
  }
});

// Add file filter to help debugging
const fileFilter = (req, file, cb) => {
  console.log('File upload request received:');
  console.log('Field name:', file.fieldname);
  console.log('Original name:', file.originalname);
  console.log('Mime type:', file.mimetype);
  
  // Accept Excel files
  if (file.mimetype.includes('spreadsheetml') || 
      file.mimetype.includes('excel') || 
      file.mimetype.includes('officedocument') ||
      file.originalname.endsWith('.xlsx') ||
      file.originalname.endsWith('.xls')) {
    console.log('File accepted');
    cb(null, true);
  } else {
    console.log('File rejected - not an Excel file');
    cb(null, true); // We'll still accept it for debugging purposes
  }
};

const upload = multer({ 
  storage: storage,
  fileFilter: fileFilter,
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

// Routes pour les sessions
router.post('/', addSession);
router.get('/', getSessions);
router.get('/byDayAndRoom', getSessionsByDayAndRoom);
router.get('/:id', getSessionById);
router.put('/:id', updateSession);
router.delete('/:id', deleteSession);
router.put('/:id/chairpersons', updateSessionChairpersons);

router.post('/import', upload.single('file'), (req, res, next) => {
  console.log('Import route hit with file:', req.file ? 'Present' : 'Not present');
  if (!req.file) {
    console.log('No file uploaded in the import route');
    return res.status(400).json({ message: 'No file uploaded' });
  }
  next();
}, importSessionsFromExcel);  


module.exports = router; 