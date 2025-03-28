const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Session = require('./models/session');
const Subsession = require('./models/subsession');

// Load environment variables
dotenv.config();

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB connected');
    createLunchSymposium();
  })
  .catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  });

async function createLunchSymposium() {
  try {
    // Data for lunch symposium
    const lunchSymposiumData = {
      dayId: '67daaa87349bac58b66ad83c',
      roomId: '67e0abdbd899f8432337ca6c',
      title: 'Final Test: Lunch Symposium',
      chairpersons: 'Dr. Final Test',
      start: 0.5,  // 12:00 in decimal format
      end: 0.625   // 15:00 in decimal format
    };
    
    // Calculate midpoint time for subsessions
    const midTime = (lunchSymposiumData.start + lunchSymposiumData.end) / 2;
    
    // Create the first subsession
    console.log('Creating first subsession...');
    const subsession1 = new Subsession({
      title: 'Final Test: First Subsession',
      startTime: String(lunchSymposiumData.start),
      endTime: String(midTime),
      speakerIds: ['67e0a86cd899f8432337c957', '67e0a86cd899f8432337c954']
    });
    
    // Create the second subsession
    console.log('Creating second subsession...');
    const subsession2 = new Subsession({
      title: 'Final Test: Second Subsession',
      startTime: String(midTime),
      endTime: String(lunchSymposiumData.end),
      speakerIds: ['67e0a876d899f8432337ca32']
    });
    
    // Save both subsessions
    const savedSubsession1 = await subsession1.save();
    console.log('First subsession saved with ID:', savedSubsession1._id);
    
    const savedSubsession2 = await subsession2.save();
    console.log('Second subsession saved with ID:', savedSubsession2._id);
    
    // Now create the lunch symposium with references to the subsessions
    console.log('Creating lunch symposium...');
    const lunchSymposium = new Session({
      title: lunchSymposiumData.title,
      dayId: new mongoose.Types.ObjectId(lunchSymposiumData.dayId),
      roomId: new mongoose.Types.ObjectId(lunchSymposiumData.roomId),
      startTime: String(lunchSymposiumData.start),  // Required by schema
      endTime: String(lunchSymposiumData.end),      // Required by schema
      type: 'Lunch Symposium',
      chairpersons: lunchSymposiumData.chairpersons,
      labLogoUrl: 'https://example.com/final-logo.png',
      // Reference the subsessions by ID
      subsessions: [
        savedSubsession1._id,
        savedSubsession2._id
      ]
    });
    
    // Save the lunch symposium
    const savedLunchSymposium = await lunchSymposium.save();
    console.log('Lunch symposium saved with ID:', savedLunchSymposium._id);
    
    // Get the saved lunch symposium with populated subsessions
    const populatedLunchSymposium = await Session.findById(savedLunchSymposium._id)
      .populate('dayId')
      .populate('roomId')
      .populate('subsessions');
    
    console.log('\nSaved Lunch Symposium:');
    console.log('Title:', populatedLunchSymposium.title);
    console.log('Day:', populatedLunchSymposium.dayId ? populatedLunchSymposium.dayId.name : 'Unknown');
    console.log('Room:', populatedLunchSymposium.roomId ? populatedLunchSymposium.roomId.name : 'Unknown');
    console.log('Start Time:', populatedLunchSymposium.startTime);
    console.log('End Time:', populatedLunchSymposium.endTime);
    console.log('Type:', populatedLunchSymposium.type);
    console.log('Chairpersons:', populatedLunchSymposium.chairpersons);
    console.log('Lab Logo URL:', populatedLunchSymposium.labLogoUrl);
    
    if (populatedLunchSymposium.subsessions && populatedLunchSymposium.subsessions.length > 0) {
      console.log('\nSubsessions:');
      populatedLunchSymposium.subsessions.forEach((subsession, index) => {
        console.log(`\n${index + 1}. ${subsession.title}`);
        console.log(`   Start Time: ${subsession.startTime}`);
        console.log(`   End Time: ${subsession.endTime}`);
        console.log(`   Speaker IDs: ${subsession.speakerIds.join(', ')}`);
      });
    }
    
    // Check all lunch symposia
    const allLunchSymposia = await Session.find({ type: 'Lunch Symposium' })
      .populate('dayId')
      .populate('roomId')
      .populate('subsessions');
    
    console.log('\nTotal Lunch Symposia in database:', allLunchSymposia.length);
    
    // Disconnect from MongoDB
    await mongoose.disconnect();
    console.log('\nMongoDB disconnected');
    
  } catch (error) {
    console.error('Error creating lunch symposium:', error);
    await mongoose.disconnect();
    console.log('MongoDB disconnected after error');
  }
} 