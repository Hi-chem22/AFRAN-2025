const mongoose = require('mongoose');
const { Session, Room, Day } = require('./models');
require('dotenv').config();

async function createTestSession() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');
    
    // Find or create a room
    let room = await Room.findOne();
    if (!room) {
      console.log('Creating test room...');
      room = await Room.create({ name: 'Test Room' });
    }
    
    // Find or create a day
    let day = await Day.findOne();
    if (!day) {
      console.log('Creating test day...');
      day = await Day.create({ 
        number: 1,
        date: new Date('2025-04-15')
      });
    }
    
    // Create a test session
    console.log('Creating test session...');
    const session = await Session.create({
      title: 'Test Session for Subsubsessions',
      room: room.name,
      roomId: room._id,
      day: day.number,
      dayId: day._id,
      startTime: '09:00',
      endTime: '12:00',
      description: 'This is a test session for testing subsubsessions',
      chairpersons: 'Test Chair',
      speakers: [],
      subsessionTexts: []
    });
    
    console.log(`Created session: ${session.title} with ID: ${session._id}`);
    
    // Disconnect
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
    
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

createTestSession(); 