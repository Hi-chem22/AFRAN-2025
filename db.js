const { MongoClient, ServerApiVersion } = require('mongodb');

// Original connection string
const username = "hichem";
const password = "KEKC5B6EumkFl5cT";
const encodedPassword = encodeURIComponent(password);

// Connection string with encoded password
const uri = `mongodb://${username}:${encodedPassword}@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=Cluster0`;

// Create a MongoClient with a MongoClientOptions object to set the Stable API version
const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  },
  connectTimeoutMS: 30000,
  socketTimeoutMS: 30000
});

async function connectToMongoDB() {
  try {
    // Connect the client to the server
    console.log("Attempting to connect to MongoDB server...");
    await client.connect();
    
    // Send a ping to confirm a successful connection
    await client.db("admin").command({ ping: 1 });
    console.log("Successfully connected to MongoDB!");
    
    // List available databases
    console.log("Listing available databases:");
    const dbList = await client.db().admin().listDatabases();
    console.log("Databases:");
    dbList.databases.forEach(db => console.log(` - ${db.name}`));
  } catch (err) {
    console.error("MongoDB Connection Error:", err);
    
    // Additional debugging information
    if (err.code === 8000 || err.message.includes('authentication failed')) {
      console.log("\nAuthentication error detected. Please check:");
      console.log("1. Username and password are correct");
      console.log("2. The IP address you're connecting from is whitelisted in MongoDB Atlas");
      console.log("3. The user has appropriate permissions for the database");
      console.log("\nConnection string being used (password hidden):");
      console.log(`mongodb://${username}:****@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=Cluster0`);
    }
  } finally {
    // Ensures that the client will close when you finish/error
    await client.close();
    console.log("MongoDB connection closed");
  }
}

// Run the connection function
connectToMongoDB().catch(console.dir); 