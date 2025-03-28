const { MongoClient } = require('mongodb');

// Connection details
const username = "admin";
const password = "40221326Hi"; 
const dbName = "afranDB";

// Connection URI without any cluster-specific part
const uri = `mongodb+srv://${username}:${password}@congresscluster.mongodb.net/${dbName}?retryWrites=true&w=majority`;

// Create client with simpler options compatible with Node.js v16
const client = new MongoClient(uri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  connectTimeoutMS: 30000
});

async function connectToDatabase() {
  try {
    console.log("Connecting to MongoDB Atlas...");
    await client.connect();
    console.log("Connected successfully!");
    
    const db = client.db(dbName);
    
    // List collections
    console.log(`\nCollections in database ${dbName}:`);
    const collections = await db.listCollections().toArray();
    
    if (collections.length === 0) {
      console.log("No collections found in this database");
    } else {
      collections.forEach(coll => {
        console.log(` - ${coll.name}`);
      });
      
      // Get a count from each collection
      console.log("\nCollection stats:");
      for (const coll of collections) {
        const count = await db.collection(coll.name).countDocuments();
        console.log(` - ${coll.name}: ${count} documents`);
      }
    }
  } catch (err) {
    console.error("Connection error:", err);
    console.log("\nPossible solutions:");
    console.log("1. Make sure your IP address is whitelisted in MongoDB Atlas");
    console.log("2. Verify your username and password");
    console.log("3. Check if the cluster name 'congresscluster' is correct");
    console.log("4. Try using MongoDB Compass with the same connection string");
  } finally {
    await client.close();
    console.log("\nConnection closed");
  }
}

connectToDatabase().catch(console.error); 