const mammoth = require('mammoth');
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
require('dotenv').config();

// Import your MongoDB models
const Speaker = require('./models/Speaker');
const Session = require('./models/Session');
const Room = require('./models/Room');

// Path to your DOCX file - update this with your actual file name
const docxPath = path.join(__dirname, 'data', 'congress-data.docx');

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  });

// Function to extract and process data
async function extractAndProcessData() {
  try {
    // Check if the file exists
    if (!fs.existsSync(docxPath)) {
      console.error(`❌ File not found: ${docxPath}`);
      console.log('Please place your DOCX file in the data directory with the name "congress-data.docx"');
      process.exit(1);
    }

    console.log('Starting data extraction from DOCX...');
    
    // Extract raw text from the DOCX file
    const result = await mammoth.extractRawText({ path: docxPath });
    const text = result.value;
    
    // Parse the extracted text into structured data
    const data = parseCongressData(text);
    
    // Save the structured data to a JSON file for verification
    fs.writeFileSync(
      path.join(__dirname, 'data', 'extracted-data.json'),
      JSON.stringify(data, null, 2)
    );
    
    console.log('✅ Data extracted and saved to data/extracted-data.json');
    
    // Insert the data into MongoDB
    await insertDataToMongoDB(data);
    
    console.log('✅ All data inserted into MongoDB successfully');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during extraction or insertion:', error);
    process.exit(1);
  }
}

// Function to parse the extracted text into structured data
function parseCongressData(text) {
  console.log('Parsing extracted text...');
  
  // Split the text into lines and remove empty lines
  const lines = text.split('\n').filter(line => line.trim());
  
  const speakers = [];
  const sessions = [];
  const rooms = [];
  
  let currentSection = null;
  let currentSpeaker = null;
  let currentSession = null;
  let currentRoom = null;
  
  // Example parsing logic - customize based on your document structure
  lines.forEach((line, index) => {
    const trimmedLine = line.trim();
    
    // Identify sections in the document
    if (trimmedLine.match(/^SPEAKERS/i)) {
      currentSection = 'speakers';
      return;
    } else if (trimmedLine.match(/^SESSIONS/i)) {
      currentSection = 'sessions';
      return;
    } else if (trimmedLine.match(/^ROOMS/i)) {
      currentSection = 'rooms';
      return;
    }
    
    // Parse data based on the current section
    if (currentSection === 'speakers') {
      if (trimmedLine.match(/^Name:/i)) {
        // Start a new speaker
        currentSpeaker = {
          name: trimmedLine.replace(/^Name:/i, '').trim(),
          country: '',
          bio: '',
          image: ''
        };
        speakers.push(currentSpeaker);
      } else if (currentSpeaker && trimmedLine.match(/^Country:/i)) {
        currentSpeaker.country = trimmedLine.replace(/^Country:/i, '').trim();
      } else if (currentSpeaker && trimmedLine.match(/^Bio:/i)) {
        currentSpeaker.bio = trimmedLine.replace(/^Bio:/i, '').trim();
      } else if (currentSpeaker && trimmedLine.match(/^Image:/i)) {
        currentSpeaker.image = trimmedLine.replace(/^Image:/i, '').trim();
      } else if (currentSpeaker) {
        // Append to the bio if it's not a specific field
        currentSpeaker.bio += ' ' + trimmedLine;
      }
    } else if (currentSection === 'sessions') {
      if (trimmedLine.match(/^Title:/i)) {
        // Start a new session
        currentSession = {
          title: trimmedLine.replace(/^Title:/i, '').trim(),
          day: '',
          startTime: '',
          endTime: '',
          description: '',
          roomName: '',
          speakerNames: [],
          subsessions: []
        };
        sessions.push(currentSession);
      } else if (currentSession && trimmedLine.match(/^Day:/i)) {
        currentSession.day = parseInt(trimmedLine.replace(/^Day:/i, '').trim()) || 1;
      } else if (currentSession && trimmedLine.match(/^Start:/i)) {
        currentSession.startTime = trimmedLine.replace(/^Start:/i, '').trim();
      } else if (currentSession && trimmedLine.match(/^End:/i)) {
        currentSession.endTime = trimmedLine.replace(/^End:/i, '').trim();
      } else if (currentSession && trimmedLine.match(/^Description:/i)) {
        currentSession.description = trimmedLine.replace(/^Description:/i, '').trim();
      } else if (currentSession && trimmedLine.match(/^Room:/i)) {
        currentSession.roomName = trimmedLine.replace(/^Room:/i, '').trim();
      } else if (currentSession && trimmedLine.match(/^Speaker:/i)) {
        const speakerName = trimmedLine.replace(/^Speaker:/i, '').trim();
        if (speakerName) {
          currentSession.speakerNames.push(speakerName);
        }
      } else if (currentSession && trimmedLine.match(/^Subsession:/i)) {
        const subsession = {
          title: trimmedLine.replace(/^Subsession:/i, '').trim(),
          description: '',
          speakerNames: []
        };
        currentSession.subsessions.push(subsession);
      } else if (currentSession && currentSession.subsessions.length > 0 && trimmedLine.match(/^SubDescription:/i)) {
        currentSession.subsessions[currentSession.subsessions.length - 1].description = 
          trimmedLine.replace(/^SubDescription:/i, '').trim();
      } else if (currentSession && currentSession.subsessions.length > 0 && trimmedLine.match(/^SubSpeaker:/i)) {
        const speakerName = trimmedLine.replace(/^SubSpeaker:/i, '').trim();
        if (speakerName) {
          currentSession.subsessions[currentSession.subsessions.length - 1].speakerNames.push(speakerName);
        }
      } else if (currentSession) {
        // Append to the description if it's not a specific field
        currentSession.description += ' ' + trimmedLine;
      }
    } else if (currentSection === 'rooms') {
      if (trimmedLine.match(/^Name:/i)) {
        // Start a new room
        currentRoom = {
          name: trimmedLine.replace(/^Name:/i, '').trim(),
          capacity: 0,
          location: ''
        };
        rooms.push(currentRoom);
      } else if (currentRoom && trimmedLine.match(/^Capacity:/i)) {
        currentRoom.capacity = parseInt(trimmedLine.replace(/^Capacity:/i, '').trim()) || 0;
      } else if (currentRoom && trimmedLine.match(/^Location:/i)) {
        currentRoom.location = trimmedLine.replace(/^Location:/i, '').trim();
      }
    }
  });
  
  return { speakers, sessions, rooms };
}

// Function to insert the parsed data into MongoDB
async function insertDataToMongoDB(data) {
  console.log('Inserting data into MongoDB...');
  
  // Clear existing data (optional)
  await Promise.all([
    Speaker.deleteMany({}),
    Session.deleteMany({}),
    Room.deleteMany({})
  ]);
  
  console.log('Existing data cleared from database');
  
  // Insert rooms
  const roomDocs = await Room.insertMany(data.rooms);
  console.log(`${roomDocs.length} rooms inserted`);
  
  // Create a map of room names to room IDs
  const roomMap = {};
  roomDocs.forEach(room => {
    roomMap[room.name] = room._id;
  });
  
  // Insert speakers
  const speakerDocs = await Speaker.insertMany(data.speakers);
  console.log(`${speakerDocs.length} speakers inserted`);
  
  // Create a map of speaker names to speaker IDs
  const speakerMap = {};
  speakerDocs.forEach(speaker => {
    speakerMap[speaker.name] = speaker._id;
  });
  
  // Process sessions to replace speaker names and room names with their IDs
  const processedSessions = data.sessions.map(session => {
    const processedSession = {
      ...session,
      speakers: session.speakerNames
        .map(name => speakerMap[name])
        .filter(id => id), // Filter out undefined IDs
      room: roomMap[session.roomName],
      subsessions: session.subsessions.map(subsession => ({
        ...subsession,
        speakers: subsession.speakerNames
          .map(name => speakerMap[name])
          .filter(id => id) // Filter out undefined IDs
      }))
    };
    
    // Remove the temporary fields
    delete processedSession.speakerNames;
    delete processedSession.roomName;
    processedSession.subsessions.forEach(sub => {
      delete sub.speakerNames;
    });
    
    return processedSession;
  });
  
  // Insert sessions
  const sessionDocs = await Session.insertMany(processedSessions);
  console.log(`${sessionDocs.length} sessions inserted`);
}

// Run the main function
extractAndProcessData(); 