const { MongoClient } = require('mongodb');

// Direct connection string as provided without any modifications
const uri = "mongodb://hichem:KEKC5B6EumkFl5cT@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=Cluster0";

// Create client without any additional options that could interfere
const client = new MongoClient(uri);

async function connect() {
  try {
    console.log("Connecting to MongoDB Atlas...");
    await client.connect();
    console.log("✅ CONNECTION SUCCESSFUL!");
    
    // List databases
    console.log("\nAvailable databases:");
    const databasesList = await client.db().admin().listDatabases();
    databasesList.databases.forEach(db => console.log(` - ${db.name}`));
    
    return true;
  } catch (err) {
    console.error("❌ CONNECTION FAILED");
    console.error(`Error: ${err.message}`);
    
    if (err.message.includes('authentication failed')) {
      console.log("\nThis appears to be an authentication error. Please check:");
      console.log("1. The password contains special characters that need escaping");
      console.log("2. The username 'hichem' is correct");
      console.log("3. Your IP address is whitelisted in MongoDB Atlas");
    }
    
    return false;
  } finally {
    await client.close();
    console.log("MongoDB connection closed");
  }
}

connect().catch(console.error); 