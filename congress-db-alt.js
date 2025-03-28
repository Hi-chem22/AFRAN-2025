const { MongoClient } = require('mongodb');

// Connection details
const username = "admin";
const password = "KEKC5B6EumkFl5cT"; // Without angle brackets
const encodedPassword = encodeURIComponent(password);
const dbName = "congressDB";

// Try with direct shard connection string (this is a guess at the shard names based on the pattern)
const uri = `mongodb://${username}:${encodedPassword}@congresscluster-shard-00-00.mongodb.net:27017,congresscluster-shard-00-01.mongodb.net:27017,congresscluster-shard-00-02.mongodb.net:27017/${dbName}?ssl=true&replicaSet=atlas-something&authSource=admin&retryWrites=true&w=majority`;

console.log("Attempting to connect with direct shard connection...");
console.log("Note: This is a best-guess attempt with the information provided.");
console.log("Connection string format: mongodb://username:password@shard1,shard2,shard3/dbName?options");

const client = new MongoClient(uri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
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
    console.error("Connection error:", err);
    console.log("\nImportant troubleshooting steps:");
    console.log("1. Verify the exact connection string from MongoDB Atlas dashboard");
    console.log("2. Make sure to whitelist your IP address in MongoDB Atlas");
    console.log("3. Check that your username and password are correct");
    console.log("4. Ensure your Atlas cluster is running and accessible");
  } finally {
    await client.close();
    console.log("Connection closed");
  }
}

run().catch(console.error); 