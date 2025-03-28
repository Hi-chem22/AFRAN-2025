const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Create Express app
const app = express();

// Configure multer storage
const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    const dir = path.join(__dirname, 'uploads');
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    cb(null, dir);
  },
  filename: function(req, file, cb) {
    cb(null, 'test-' + Date.now() + path.extname(file.originalname));
  }
});

// Create multer upload instance
const upload = multer({ storage: storage });

// Middleware to log request details
app.use((req, res, next) => {
  console.log('Request received:', req.method, req.url);
  console.log('Headers:', req.headers);
  next();
});

// Test route for file uploads
app.post('/upload', upload.single('file'), (req, res) => {
  console.log('Upload request body:', req.body);
  console.log('Upload request file:', req.file);
  
  if (!req.file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }
  
  res.json({
    message: 'File uploaded successfully',
    file: req.file
  });
});

// Start server
const PORT = 8090;
app.listen(PORT, () => {
  console.log(`Test server running on port ${PORT}`);
  console.log(`Upload endpoint: http://localhost:${PORT}/upload`);
}); 