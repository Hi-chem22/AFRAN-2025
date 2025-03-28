const { MongoClient } = require('mongodb');

// New connection details with the password "40221326Hi"
const username = "hichem";
const password = "40221326Hi";

// Connection URI - direct shard connection
const uri = `mongodb://${username}:${password}@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin`;

// Create a new MongoClient
const client = new MongoClient(uri);

async function run() {
  try {
    console.log("Connecting to MongoDB with new password...");
    await client.connect();
    console.log("✅ CONNECTION SUCCESSFUL!");
    
    // List available databases
    console.log("\nAvailable databases:");
    const dbList = await client.db().admin().listDatabases();
    dbList.databases.forEach(db => console.log(` - ${db.name}`));
    
    // Test access to specific databases
    console.log("\nTesting access to specific databases:");
    
    try {
      const afranDB = client.db("afranDB");
      const collections = await afranDB.listCollections().toArray();
      console.log("\nCollections in afranDB:");
      if (collections.length === 0) {
        console.log(" - No collections found");
      } else {
        collections.forEach(coll => console.log(` - ${coll.name}`));
      }
    } catch (err) {
      console.log("Error accessing afranDB:", err.message);
    }
    
  } catch (err) {
    console.error("Connection error:", err);
    console.log("\nPossible issues:");
    console.log("1. Password might be incorrect - check for typos");
    console.log("2. Your IP address might not be properly whitelisted");
    console.log("3. Network connectivity issues");
  } finally {
    await client.close();
    console.log("\nConnection closed");
  }
}

run().catch(console.error); 