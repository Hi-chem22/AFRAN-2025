const { MongoClient, ServerApiVersion } = require('mongodb');

// Connection details for congressDB
const username = "admin";
const password = "KEKC5B6EumkFl5cT"; // Without angle brackets
const encodedPassword = encodeURIComponent(password);
const cluster = "congresscluster.mongodb.net";
const dbName = "congressDB";

// Connection URI
const uri = `mongodb+srv://${username}:${encodedPassword}@${cluster}/${dbName}?retryWrites=true&w=majority`;

// Create a MongoClient with a MongoClientOptions object
const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  },
  connectTimeoutMS: 30000
});

async function connectToCongressDB() {
  try {
    // Connect to the MongoDB server
    console.log("Connecting to CongressDB...");
    await client.connect();
    
    // Confirm connection with a ping
    await client.db("admin").command({ ping: 1 });
    console.log("Successfully connected to MongoDB CongressDB!");
    
    // Get database info
    const db = client.db(dbName);
    
    // List collections in the database
    console.log(`\nCollections in ${dbName}:`);
    const collections = await db.listCollections().toArray();
    
    if (collections.length === 0) {
      console.log("No collections found in this database.");
    } else {
      collections.forEach(collection => {
        console.log(` - ${collection.name}`);
      });
      
      // Show sample data from the first collection if any exist
      if (collections.length > 0) {
        const firstCollection = collections[0].name;
        console.log(`\nSample documents from '${firstCollection}' collection:`);
        const documents = await db.collection(firstCollection).find().limit(3).toArray();
        console.log(JSON.stringify(documents, null, 2));
      }
    }
  } catch (err) {
    console.error("Error connecting to CongressDB:", err);
    console.log("\nPossible solutions:");
    console.log("1. Check if username and password are correct");
    console.log("2. Make sure your IP address is whitelisted in MongoDB Atlas");
    console.log("3. Verify that the database name and cluster name are correct");
  } finally {
    // Close the connection
    await client.close();
    console.log("\nMongoDB connection closed");
  }
}

// Run the function
connectToCongressDB().catch(console.error); 