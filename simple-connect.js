const { MongoClient } = require('mongodb');

// Simplified connection string with no ServerApi options
const uri = "mongodb+srv://hichem:KEKC5B6EumkFl5cT@cluster0.pt98b.mongodb.net/";

// Create a basic client with no extra options
const client = new MongoClient(uri);

async function connect() {
  try {
    console.log("Connecting to MongoDB with simplified settings...");
    await client.connect();
    console.log("Connected to MongoDB!");
    
    // List databases
    console.log("\nListing databases:");
    const dbs = await client.db().admin().listDatabases();
    dbs.databases.forEach(db => {
      console.log(` - ${db.name}`);
    });

  } catch (err) {
    console.error("Connection error:", err);
  } finally {
    await client.close();
    console.log("Connection closed");
  }
}

connect().catch(console.error); 