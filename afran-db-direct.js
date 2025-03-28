const { MongoClient } = require('mongodb');

// Connection details
const username = "admin";
const password = "KEKC5B6EumkFl5cT"; // Without angle brackets
const encodedPassword = encodeURIComponent(password);
const dbName = "afranDB";

// Try standard connection string instead of SRV
const uri = `mongodb://${username}:${encodedPassword}@congresscluster.mongodb.net:27017/${dbName}?ssl=true&authSource=admin&retryWrites=true&w=majority`;

console.log("Attempting direct connection to MongoDB Atlas...");
console.log("Using standard connection format instead of SRV");

const client = new MongoClient(uri, {
  connectTimeoutMS: 30000
});

async function run() {
  try {
    console.log("Connecting to database...");
    await client.connect();
    console.log("Connected successfully!");
    
    // Test database connection
    const db = client.db(dbName);
    const collections = await db.listCollections().toArray();
    
    console.log(`Collections in ${dbName}:`);
    if (collections.length === 0) {
      console.log("No collections found.");
    } else {
      collections.forEach(collection => {
        console.log(` - ${collection.name}`);
      });
    }
  } catch (err) {
    console.error("Connection error:", err.message);
    console.log("\nDetailed error information:");
    console.log(err);
    
    console.log("\nTroubleshooting steps:");
    console.log("1. Verify the exact connection string from MongoDB Atlas dashboard");
    console.log("2. Make sure to whitelist your IP address in MongoDB Atlas");
    console.log("3. Check that the username (admin) and password are correct");
    console.log("4. Verify that the hostname (congresscluster.mongodb.net) is correct");
    console.log("5. Try connecting using MongoDB Compass with the same connection string");
  } finally {
    await client.close();
    console.log("Connection closed");
  }
}

run().catch(console.error); 