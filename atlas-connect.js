const { MongoClient } = require('mongodb');

// Replace with your actual values
const username = "admin";
const password = "KEKC5B6EumkFl5cT"; // Without angle brackets
const cluster = "congresscluster";
const dbName = "afranDB";

// Connection URI exactly following Atlas format
const uri = `mongodb+srv://${username}:${password}@${cluster}.gfpnaxs.mongodb.net/?retryWrites=true&w=majority`;

// Create a new MongoClient
const client = new MongoClient(uri);

async function run() {
  try {
    // Connect the client to the server
    console.log("Attempting to connect to MongoDB Atlas...");
    await client.connect();
    
    // Access the database
    const database = client.db(dbName);
    console.log(`Successfully connected to database: ${dbName}`);
    
    // List collections
    const collections = await database.listCollections().toArray();
    console.log("\nCollections:");
    if (collections.length === 0) {
      console.log("No collections found");
    } else {
      collections.forEach(coll => console.log(` - ${coll.name}`));
    }
  } catch (err) {
    console.error("Connection failed:", err);
    console.log("\nPlease verify:");
    console.log("1. Check if cluster name is correct. It's likely NOT 'congresscluster'");
    console.log("2. Check if your MongoDB Atlas URL includes a different cluster identifier");
    console.log("3. Make sure your IP is whitelisted in Atlas (Network Access section)");
    console.log("4. Verify username and password");
  } finally {
    // Ensures that the client will close when you finish/error
    await client.close();
    console.log("Connection closed");
  }
}

run().catch(console.dir); 