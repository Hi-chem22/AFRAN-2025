const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Session = require('./models/session');

// Load environment variables
dotenv.config();

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB connected');
    
    // Find lunch symposia sessions
    const lunchSymposia = await Session.find({ type: 'Lunch Symposium' })
      .populate('dayId')
      .populate('roomId');

    console.log('Number of lunch symposia found:', lunchSymposia.length);
    
    if (lunchSymposia.length > 0) {
      console.log('\nLunch Symposia Details:');
      lunchSymposia.forEach((symposium, index) => {
        console.log(`\n--- Symposium ${index + 1} ---`);
        console.log('ID:', symposium._id);
        console.log('Title:', symposium.title);
        console.log('Chairpersons:', symposium.chairpersons);
        console.log('Day:', symposium.dayId ? symposium.dayId.name : 'Unknown');
        console.log('Room:', symposium.roomId ? symposium.roomId.name : 'Unknown');
        console.log('Lab Logo URL:', symposium.labLogoUrl);
        
        console.log('Subsessions:');
        if (symposium.subsessions && symposium.subsessions.length > 0) {
          symposium.subsessions.forEach((subsession, subIndex) => {
            console.log(`  ${subIndex + 1}. ${subsession.title}`);
          });
        } else {
          console.log('  No subsessions found');
        }
      });
    } else {
      console.log('\nNo lunch symposia found in the database.');
    }
    
    // Find all sessions
    const allSessions = await Session.find();
    console.log(`\nTotal sessions in database: ${allSessions.length}`);
    
    // Show session types
    const sessionTypes = allSessions.reduce((types, session) => {
      const type = session.type || 'Regular';
      types[type] = (types[type] || 0) + 1;
      return types;
    }, {});
    
    console.log('\nSession types:');
    Object.entries(sessionTypes).forEach(([type, count]) => {
      console.log(`${type}: ${count}`);
    });
    
    // Disconnect from MongoDB
    await mongoose.disconnect();
    console.log('\nMongoDB disconnected');
    
  } catch (error) {
    console.error('Error connecting to MongoDB:', error.message);
    process.exit(1);
  }
};

// Run the function
connectDB(); 