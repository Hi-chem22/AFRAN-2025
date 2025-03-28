const { MongoClient } = require('mongodb');
const uri = 'mongodb://hichem:40221326Hi@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin';

async function loadMongoDBAtlas() {
  const client = new MongoClient(uri);
  try {
    await client.connect();
    console.log('Connected to MongoDB Atlas successfully!');
    
    const db = client.db('AfranDB');
    const collections = await db.listCollections().toArray();
    
    console.log(`\nFound ${collections.length} collections in AfranDB:`);
    
    // Display collection stats
    for (const collection of collections) {
      const count = await db.collection(collection.name).countDocuments();
      console.log(`- ${collection.name}: ${count} documents`);
    }
    
    // Display sessions
    const sessions = await db.collection('sessions').find().toArray();
    console.log('\n=== SESSIONS ===');
    sessions.forEach((session, i) => {
      console.log(`\n${i+1}. ${session.title} (${session.startTime} - ${session.endTime})`);
      console.log(`   Type: ${session.type}`);
      console.log(`   Interventions: ${session.interventions ? session.interventions.length : 0}`);
    });
    
    // Display speakers
    const speakers = await db.collection('speakers').find().toArray();
    console.log('\n=== SPEAKERS ===');
    speakers.forEach((speaker, i) => {
      console.log(`\n${i+1}. ${speaker.name} - ${speaker.country}`);
      console.log(`   Title: ${speaker.title || 'N/A'}`);
    });
    
    // Display rooms
    const rooms = await db.collection('rooms').find().toArray();
    console.log('\n=== ROOMS ===');
    rooms.forEach((room, i) => {
      console.log(`${i+1}. ${room.name} (Capacity: ${room.capacity})`);
    });
    
    // Display days
    const days = await db.collection('days').find().toArray();
    console.log('\n=== DAYS ===');
    days.forEach((day, i) => {
      console.log(`${i+1}. ${day.dayName}, ${day.date.toDateString()} (Day ${day.dayNumber})`);
    });
    
  } catch (err) {
    console.error('Error connecting to MongoDB:', err);
  } finally {
    await client.close();
    console.log('\nConnection closed');
  }
}

loadMongoDBAtlas().catch(console.error); 