const { MongoClient } = require('mongodb');

// Using admin username instead of hichem
const uri = "mongodb://admin:KEKC5B6EumkFl5cT@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=Cluster0";

// Create a MongoDB client
const client = new MongoClient(uri, {
  connectTimeoutMS: 30000
});

async function connectToMongoDB() {
  try {
    console.log("Connecting to MongoDB with username 'admin'...");
    await client.connect();
    console.log("✅ Successfully connected to MongoDB!");
    
    // List all databases
    console.log("\nListing available databases:");
    const dbList = await client.db().admin().listDatabases();
    
    if (dbList.databases.length === 0) {
      console.log("No databases found");
    } else {
      dbList.databases.forEach(db => {
        console.log(` - ${db.name}`);
      });
      
      // Check for specific databases
      console.log("\nChecking for specific databases:");
      const dbNames = dbList.databases.map(db => db.name);
      
      if (dbNames.includes("afranDB")) {
        console.log(" - 'afranDB' found ✓");
      } else {
        console.log(" - 'afranDB' not found ✗");
      }
      
      if (dbNames.includes("congressDB")) {
        console.log(" - 'congressDB' found ✓");
      } else {
        console.log(" - 'congressDB' not found ✗");
      }
    }
  } catch (err) {
    console.error("Connection error:", err);
    console.log("\nPossible issues:");
    console.log("1. IP address not whitelisted in MongoDB Atlas");
    console.log("2. Invalid credentials (username/password)");
    console.log("3. Network connectivity issues");
  } finally {
    await client.close();
    console.log("\nMongoDB connection closed");
  }
}

connectToMongoDB().catch(console.error); 