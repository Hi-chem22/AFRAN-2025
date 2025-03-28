const xlsx = require('xlsx');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Session = require('./models/session');
const Subsession = require('./models/subsession');

// Load environment variables
dotenv.config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('MongoDB connection error:', err));

async function importLunchSymposia(excelFilePath) {
  try {
    // Read the Excel file
    const workbook = xlsx.readFile(excelFilePath);
    
    // Get the sheets
    const symposiaSheet = workbook.Sheets['symposia'];
    const subsessionsSheet = workbook.Sheets['subsessions'];
    
    // Convert sheets to JSON
    const symposiaData = xlsx.utils.sheet_to_json(symposiaSheet);
    const subsessionsData = xlsx.utils.sheet_to_json(subsessionsSheet);
    
    // Process each symposium
    for (const symposium of symposiaData) {
      // Create the main session (symposium)
      const session = new Session({
        title: symposium['Symposium Title'],
        roomId: symposium['RoomId'],
        dayId: symposium['DayId'],
        startTime: symposium['Start Time'],
        endTime: symposium['End Time'],
        type: 'Lunch Symposium',
        labLogoUrl: symposium['Lab Logo URL'],
        chairpersons: symposium['Chairperson(s)']
      });
      
      await session.save();
      
      // Find and process all subsessions for this symposium
      const symposiumSubsessions = subsessionsData.filter(
        sub => sub['Symposium Title'] === symposium['Symposium Title']
      );
      
      for (const sub of symposiumSubsessions) {
        const subsession = new Subsession({
          title: sub['Title'],
          startTime: sub['Start Time'],
          endTime: sub['End Time'],
          description: sub['Description'],
          speakerId: sub['Speaker ID'],
          sessionId: session._id
        });
        
        await subsession.save();
        
        // Add subsession reference to the session
        session.subsessions.push(subsession._id);
      }
      
      await session.save();
      console.log(`Imported symposium: ${session.title}`);
    }
    
    console.log('Import completed successfully');
  } catch (error) {
    console.error('Error during import:', error);
  } finally {
    // Close MongoDB connection
    await mongoose.connection.close();
  }
}

// Check if file path is provided as command line argument
const excelFilePath = process.argv[2];
if (!excelFilePath) {
  console.error('Please provide the Excel file path as an argument');
  process.exit(1);
}

importLunchSymposia(excelFilePath); 