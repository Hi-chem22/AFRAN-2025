const { MongoClient } = require('mongodb');
const uri = 'mongodb://hichem:40221326Hi@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin';

async function listSpeakers() {
  const client = new MongoClient(uri);
  try {
    await client.connect();
    console.log('Connected to MongoDB Atlas');
    
    const db = client.db('AfranDB');
    const speakers = await db.collection('speakers').find().toArray();
    
    console.log(`\nFound ${speakers.length} speakers:`);
    
    speakers.forEach((speaker, index) => {
      console.log(`\n${index + 1}. ${speaker.name} - ${speaker.country}`);
      console.log(`   Title: ${speaker.title || 'N/A'}`);
      console.log(`   Bio: ${speaker.bio ? speaker.bio.substring(0, 80) + '...' : 'N/A'}`);
      console.log(`   Affiliations: ${speaker.affiliations ? speaker.affiliations.join(', ') : 'None'}`);
    });
    
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await client.close();
  }
}

listSpeakers(); 