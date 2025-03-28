const { MongoClient } = require('mongodb');

// The password might contain special characters that need proper URL encoding
// Let's try breaking down the connection string and properly encoding each part
const username = "hichem";
const password = encodeURIComponent("KEKC5B6EumkFl5cT");
const host1 = "cluster0-shard-00-00.pt98b.mongodb.net:27017";
const host2 = "cluster0-shard-00-01.pt98b.mongodb.net:27017";
const host3 = "cluster0-shard-00-02.pt98b.mongodb.net:27017";
const options = "replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=Cluster0";

// Build the connection string with properly encoded password
const uri = `mongodb://${username}:${password}@${host1},${host2},${host3}/?${options}`;

console.log("Using connection string with encoded password:");
console.log(uri.replace(password, "****"));

// Create MongoDB client
const client = new MongoClient(uri);

async function connect() {
  try {
    console.log("\nConnecting to MongoDB Atlas...");
    await client.connect();
    console.log("✅ Connection successful!");
    
    // List databases
    console.log("\nAvailable databases:");
    const databasesList = await client.db().admin().listDatabases();
    databasesList.databases.forEach(db => console.log(` - ${db.name}`));
    
    return true;
  } catch (err) {
    console.error("❌ Connection failed");
    
    // Show detailed error information
    if (err.name === 'MongoServerError') {
      console.error(`MongoDB Server Error: ${err.message}`);
      if (err.code) {
        console.error(`Error code: ${err.code}`);
      }
      
      // If we have an error response, show it
      if (err.errorResponse) {
        console.error("Error response:", err.errorResponse);
      }
    } else {
      console.error(`Error: ${err.message}`);
    }
    
    console.log("\nTroubleshooting suggestions:");
    console.log("1. Verify your MongoDB Atlas username and password");
    console.log("2. Make sure your IP address is whitelisted in MongoDB Atlas Network Access settings");
    console.log("3. Check if your MongoDB Atlas cluster is active");
    console.log("4. Verify the connection string format from MongoDB Atlas dashboard");
    
    return false;
  } finally {
    await client.close();
    console.log("MongoDB connection closed");
  }
}

connect().catch(console.error); 