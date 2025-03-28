const express = require('express');
const multer = require('multer');
const path = require('path');
const XLSX = require('xlsx');
const fs = require('fs');

const app = express();
const PORT = 8091;

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, 'uploads'));
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now();
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const upload = multer({ storage: storage });

// Middleware to log request details
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  if (req.method === 'POST') {
    console.log('Headers:', req.headers);
    console.log('Body:', req.body);
  }
  next();
});

// Test route for session imports
app.post('/import', upload.single('file'), async (req, res) => {
  console.log('Request received at /import');
  console.log('Request files:', req.file);
  
  if (!req.file) {
    console.log('No file uploaded');
    return res.status(400).json({ message: 'No file uploaded' });
  }
  
  console.log(`File uploaded: ${req.file.path}`);
  
  try {
    // Read the Excel file
    const workbook = XLSX.readFile(req.file.path);
    console.log('Excel file read successfully');
    
    // Check if Sessions sheet exists
    if (!workbook.SheetNames.includes('Sessions')) {
      return res.status(400).json({ message: 'Excel file must contain a "Sessions" sheet' });
    }
    
    const sessionsSheet = workbook.Sheets['Sessions'];
    const sessions = XLSX.utils.sheet_to_json(sessionsSheet);
    
    if (sessions.length === 0) {
      return res.status(400).json({ message: 'No sessions found in Excel file' });
    }
    
    console.log(`Found ${sessions.length} sessions`);
    
    // Process sessions
    const processedSessions = sessions.map(session => {
      return {
        title: session['Session Title'],
        room: session['Room'],
        day: session['Day'],
        startTime: session['Start Time'],
        endTime: session['End Time'],
        chairpersons: session['Chairs'],
        description: session['Description']
      };
    });
    
    return res.status(201).json({ 
      message: 'Sessions imported successfully', 
      count: processedSessions.length,
      sessions: processedSessions
    });
    
  } catch (error) {
    console.error('Error processing Excel file:', error);
    return res.status(500).json({ message: 'Error processing Excel file', error: error.message });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Import test server running on port ${PORT}`);
  console.log(`Upload endpoint: http://localhost:${PORT}/import`);
}); 