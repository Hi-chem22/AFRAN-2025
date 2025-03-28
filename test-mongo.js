const { MongoClient, ServerApiVersion } = require('mongodb');

// Replace with your actual password - notice we've removed the < > brackets that were in the original string
const password = "KEKC5B6EumkFl5cT";
const encodedPassword = encodeURIComponent(password);

// MongoDB Atlas connection string format
const uri = `mongodb+srv://hichem:${encodedPassword}@cluster0.pt98b.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0`;

// Create a MongoClient with a MongoClientOptions object to set the Stable API version
const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});

async function run() {
  try {
    // Connect the client to the server
    console.log("Attempting to connect to MongoDB Atlas...");
    await client.connect();
    
    // Send a ping to confirm a successful connection
    await client.db("admin").command({ ping: 1 });
    console.log("Pinged your deployment. You successfully connected to MongoDB!");
    
    // List available databases
    const dbList = await client.db().admin().listDatabases();
    console.log("Available databases:");
    dbList.databases.forEach(db => console.log(` - ${db.name}`));
  } catch (err) {
    console.error("Error connecting to MongoDB Atlas:", err);
    
    // Connection troubleshooting
    console.log("\nTroubleshooting tips:");
    console.log("1. Check if the username and password are correct");
    console.log("2. Ensure your IP address is whitelisted in MongoDB Atlas");
    console.log("3. Verify the cluster name and connection string format");
    console.log("4. Make sure your MongoDB Atlas cluster is active");
    
    // Log connection string (hiding password)
    console.log("\nConnection string used (password hidden):");
    console.log(`mongodb+srv://hichem:****@cluster0.pt98b.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0`);
  } finally {
    // Ensures that the client will close when you finish/error
    await client.close();
    console.log("MongoDB connection closed");
  }
}

run().catch(console.dir); 