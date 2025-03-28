const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const app = express();

// Make sure uploads directory exists
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
  console.log('Created uploads directory');
} else {
  console.log('Uploads directory exists');
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

// Create multer upload instance
const upload = multer({ 
  storage,
  fileFilter: (req, file, cb) => {
    // Log file information
    console.log('File received:', file);
    // Accept all files
    cb(null, true);
  }
});

// Test upload endpoint
app.post('/upload-test', upload.single('file'), (req, res) => {
  console.log('Upload request received');
  
  if (!req.file) {
    console.log('No file in request');
    console.log('Request body:', req.body);
    console.log('Request files:', req.files);
    return res.status(400).json({ 
      message: 'No file uploaded',
      body: req.body,
      files: req.files
    });
  }
  
  console.log('File uploaded successfully:', req.file);
  res.json({ 
    message: 'File uploaded successfully',
    file: req.file
  });
});

// Start server
const PORT = 8081;
app.listen(PORT, () => {
  console.log(`Test server running on port ${PORT}`);
  console.log(`Upload endpoint: http://localhost:${PORT}/upload-test`);
});

console.log('Test server started. Use this with Postman to test file uploads.');
console.log('Make sure to use form-data with a field named "file" set to File type.'); 