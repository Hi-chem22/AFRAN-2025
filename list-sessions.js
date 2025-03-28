const { MongoClient } = require('mongodb');
const uri = 'mongodb://hichem:40221326Hi@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin';

async function listSessions() {
  const client = new MongoClient(uri);
  try {
    await client.connect();
    console.log('Connected to MongoDB Atlas');
    
    const db = client.db('AfranDB');
    const sessions = await db.collection('sessions').find().toArray();
    
    console.log(`\nFound ${sessions.length} sessions:`);
    
    sessions.forEach((session, index) => {
      console.log(`\n${index + 1}. ${session.title}`);
      console.log(`   Type: ${session.type}`);
      console.log(`   Time: ${session.startTime} - ${session.endTime}`);
      console.log(`   Room: ${session.room}`);
      console.log(`   Moderators: ${session.moderators ? session.moderators.join(', ') : 'None'}`);
      console.log(`   Interventions: ${session.interventions ? session.interventions.length : 0}`);
    });
    
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await client.close();
  }
}

listSessions(); 