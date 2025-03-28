const { MongoClient } = require('mongodb');
const uri = 'mongodb://hichem:40221326Hi@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin';

async function testConnection() {
  const client = new MongoClient(uri);
  try {
    await client.connect();
    console.log('Connected to MongoDB Atlas');
    
    const dbs = await client.db().admin().listDatabases();
    console.log('Available databases:');
    dbs.databases.forEach(db => console.log(` - ${db.name}`));
    
    const db = client.db('AfranDB');
    const collections = await db.listCollections().toArray();
    
    console.log('\nCollections in AfranDB:');
    collections.forEach(coll => console.log(` - ${coll.name}`));
    
  } catch (err) {
    console.error('Connection error:', err);
  } finally {
    await client.close();
  }
}

testConnection(); 