const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');
const path = require('path');
const multer = require('multer');
const fs = require('fs');
// Routes
const sessionRoutes = require('./routes/sessionRoutes');
const subsessionRoutes = require('./routes/subsessionRoutes');
const speakerRoutes = require('./routes/speakerRoutes');
const sponsorRoutes = require('./routes/sponsorRoutes');
const messageRoutes = require('./routes/messageRoutes');
const adRoutes = require('./routes/adRoutes');
const roomRoutes = require('./routes/roomRoutes');
const dayRoutes = require('./routes/dayRoutes');
const chairpersonRoutes = require('./routes/chairpersonRoutes');
const partnerRoutes = require('./routes/partnerRoutes');
const videoRoutes = require('./routes/videoRoutes');
const logoRoutes = require('./routes/logoRoutes');

// Chargement des variables d'environnement
dotenv.config();

// Connexion à la base de données
connectDB();

// Initialisation du serveur Express
const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// Servir les fichiers statiques depuis le dossier uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes API
app.use('/api/sessions', sessionRoutes);
app.use('/api/subsessions', subsessionRoutes);
app.use('/api/speakers', speakerRoutes);
app.use('/api/sponsors', sponsorRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/ads', adRoutes);
app.use('/api/rooms', roomRoutes);
app.use('/api/days', dayRoutes);
app.use('/api/chairpersons', chairpersonRoutes);
app.use('/api/partners', partnerRoutes);
app.use('/api/videos', videoRoutes);
app.use('/api/logo', logoRoutes);

// Configure multer for file uploads
const uploadDir = path.join(__dirname, 'uploads');

// Ensure uploads directory exists
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure multer storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

const upload = multer({ 
  storage,
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

// Test endpoint
app.get('/api/test', (req, res) => {
  res.json({ message: 'Test endpoint working' });
});

// Logo endpoint
app.get('/api/logo/file', (req, res) => {
  const logoPath = path.join(__dirname, 'uploads', 'logo', 'congress_logo.png');
  res.sendFile(logoPath, (err) => {
    if (err) {
      res.status(404).json({ message: 'Logo file not found' });
    }
  });
});

const PORT = process.env.PORT || 8087;
const HOST = '0.0.0.0';

app.listen(PORT, HOST, () => {
  console.log(`🔥 Server started on port ${PORT}`);
  console.log(`🌐 Accessible on http://localhost:${PORT}`);
  console.log(`🌐 Accessible on http://192.168.1.5:${PORT}`);
  console.log(`🌐 Accessible on http://${HOST}:${PORT}`);
  console.log('📝 CORS is enabled for all origins');
}); 

// ✅ Lancer le serveur
