const mongoose = require('mongoose');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Define a simplified Session model directly in this script
// to avoid schema registration issues
const sessionSchema = new mongoose.Schema({
  title: String,
  roomId: mongoose.Schema.Types.ObjectId,
  dayId: mongoose.Schema.Types.ObjectId,
  type: String,
  chairpersons: String,
  startTime: String,
  endTime: String,
  labLogoUrl: String,
  subsessions: Array,
  createdAt: Date
});

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('MongoDB connected');
    
    try {
      // Create a model with a unique name to avoid conflicts
      const Session = mongoose.model('SessionCheck', sessionSchema, 'sessions');
      
      // Find all lunch symposia
      const lunchSymposia = await Session.find({ type: 'Lunch Symposium' });
      
      console.log(`Found ${lunchSymposia.length} lunch symposia in the database:\n`);
      
      if (lunchSymposia.length === 0) {
        console.log('No lunch symposia found. Checking all session types...');
        
        // Get all session types
        const sessions = await Session.find();
        const types = {};
        
        sessions.forEach(session => {
          const type = session.type || 'Unknown';
          types[type] = (types[type] || 0) + 1;
        });
        
        console.log('\nSession types in database:');
        Object.entries(types).forEach(([type, count]) => {
          console.log(`- ${type}: ${count}`);
        });
        
        console.log('\nTotal sessions:', sessions.length);
      } else {
        // List lunch symposia
        lunchSymposia.forEach((symposium, index) => {
          console.log(`${index + 1}. ${symposium.title}`);
          console.log(`   ID: ${symposium._id}`);
          console.log(`   Day ID: ${symposium.dayId}`);
          console.log(`   Room ID: ${symposium.roomId}`);
          console.log(`   Chair: ${symposium.chairpersons}`);
          console.log(`   Time: ${symposium.startTime} - ${symposium.endTime}`);
          console.log(`   Created: ${symposium.createdAt}`);
          console.log(`   Subsessions: ${symposium.subsessions.length}`);
          console.log('');
        });
      }
    } catch (error) {
      console.error('Error querying MongoDB:', error);
    } finally {
      // Disconnect from MongoDB
      await mongoose.disconnect();
      console.log('MongoDB disconnected');
    }
  })
  .catch(err => {
    console.error('Error connecting to MongoDB:', err);
  }); 