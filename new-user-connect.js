const { MongoClient } = require('mongodb');

// IMPORTANT: Replace these with your new credentials after resetting the password
// or creating a new user in MongoDB Atlas
const username = "YOUR_NEW_USERNAME"; // e.g., "testuser"
const password = "YOUR_NEW_PASSWORD"; // e.g., "password123"

// Connection string with new credentials
const uri = `mongodb+srv://${username}:${password}@cluster0.pt98b.mongodb.net/`;

// Create MongoDB client
const client = new MongoClient(uri);

async function connect() {
  try {
    console.log("Connecting to MongoDB with new credentials...");
    await client.connect();
    console.log("✅ CONNECTION SUCCESSFUL!");
    
    // List databases
    console.log("\nAvailable databases:");
    const dbs = await client.db().admin().listDatabases();
    dbs.databases.forEach(db => {
      console.log(` - ${db.name}`);
    });
    
    // Show how to use a specific database
    console.log("\nExample: To use a specific database");
    console.log(`const db = client.db("yourDatabaseName");`);
    console.log(`const collection = db.collection("yourCollectionName");`);
    
  } catch (err) {
    console.error("Connection error:", err);
    
    if (err.message.includes('authentication failed')) {
      console.log("\nStill having authentication issues?");
      console.log("1. Double-check that you've replaced the placeholder credentials in this file");
      console.log("2. Make sure the new user has appropriate permissions");
      console.log("3. Verify your MongoDB Atlas cluster is in the same region");
    }
  } finally {
    await client.close();
    console.log("\nConnection closed");
  }
}

// Instructions for how to use this file
console.log("=======================================================");
console.log("MONGODB CONNECTION WITH NEW CREDENTIALS");
console.log("=======================================================");
console.log("IMPORTANT: Before running this script:");
console.log("1. Edit this file to replace YOUR_NEW_USERNAME and YOUR_NEW_PASSWORD");
console.log("   with the credentials you created in MongoDB Atlas");
console.log("2. Save the file after making changes");
console.log("3. Run with: node new-user-connect.js");
console.log("=======================================================\n");

// Only run if credentials have been updated
if (username !== "YOUR_NEW_USERNAME" && password !== "YOUR_NEW_PASSWORD") {
  connect().catch(console.error);
} else {
  console.log("⚠️ Please update the credentials in this file before running it!");
} 