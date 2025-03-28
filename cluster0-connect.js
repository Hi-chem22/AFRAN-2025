const { MongoClient } = require('mongodb');

// Connection string directly from user input
const uri = "mongodb://hichem:KEKC5B6EumkFl5cT@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=Cluster0";

// Create a MongoDB client
const client = new MongoClient(uri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  connectTimeoutMS: 30000
});

async function connectToMongoDB() {
  try {
    console.log("Connecting to MongoDB with direct shard connection string...");
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
      
      // Try to access each database and list collections
      for (const dbName of ["afranDB", "congressDB"]) {
        if (dbNames.includes(dbName)) {
          console.log(`\nListing collections in ${dbName}:`);
          const db = client.db(dbName);
          const collections = await db.listCollections().toArray();
          
          if (collections.length === 0) {
            console.log(" - No collections found");
          } else {
            collections.forEach(coll => {
              console.log(` - ${coll.name}`);
            });
          }
        }
      }
    }
  } catch (err) {
    console.error("Connection error:", err);
    console.log("\nPossible issues:");
    console.log("1. IP address not whitelisted in MongoDB Atlas");
    console.log("2. Invalid credentials (username/password)");
    console.log("3. Network connectivity issues");
    console.log("4. The MongoDB cluster might not be active");
  } finally {
    await client.close();
    console.log("\nMongoDB connection closed");
  }
}

connectToMongoDB().catch(console.error); 