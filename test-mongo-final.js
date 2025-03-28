const { MongoClient, ServerApiVersion } = require('mongodb');

/*
Looking at the original connection string:
mongodb://hichem:<KEKC5B6EumkFl5cT>@cluster0-shard-00-00.pt98b.mongodb.net:27017...

The angle brackets might indicate a placeholder rather than part of the password.
Let's try without the angle brackets.
*/

// Connection options
const username = "hichem";
const password = "KEKC5B6EumkFl5cT"; // Without angle brackets
const encodedPassword = encodeURIComponent(password);

// Connection strings to try (both SRV and standard formats)
const uriSrv = `mongodb+srv://${username}:${encodedPassword}@cluster0.pt98b.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0`;
const uriStandard = `mongodb://${username}:${encodedPassword}@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=Cluster0`;

// Create clients for both connection strings
const clientSrv = new MongoClient(uriSrv, {
  serverApi: { version: ServerApiVersion.v1, strict: true, deprecationErrors: true }
});

const clientStandard = new MongoClient(uriStandard, {
  serverApi: { version: ServerApiVersion.v1, strict: true, deprecationErrors: true }
});

async function testConnection() {
  console.log("===== Testing MongoDB Atlas Connection =====");
  console.log("Attempting both SRV and standard connection formats...");
  
  // Try SRV connection
  console.log("\n--- Testing SRV connection format ---");
  try {
    await clientSrv.connect();
    await clientSrv.db("admin").command({ ping: 1 });
    console.log("✅ SRV Connection succeeded!");
    
    const dbList = await clientSrv.db().admin().listDatabases();
    console.log("Available databases:");
    dbList.databases.forEach(db => console.log(` - ${db.name}`));
  } catch (err) {
    console.error("❌ SRV Connection failed:", err.message);
  } finally {
    await clientSrv.close();
  }
  
  // Try standard connection
  console.log("\n--- Testing standard connection format ---");
  try {
    await clientStandard.connect();
    await clientStandard.db("admin").command({ ping: 1 });
    console.log("✅ Standard Connection succeeded!");
    
    const dbList = await clientStandard.db().admin().listDatabases();
    console.log("Available databases:");
    dbList.databases.forEach(db => console.log(` - ${db.name}`));
  } catch (err) {
    console.error("❌ Standard Connection failed:", err.message);
  } finally {
    await clientStandard.close();
  }
  
  console.log("\n===== Connection Testing Complete =====");
  console.log("If both connection methods failed, please check:");
  console.log("1. Username and password accuracy - make sure you're using the exact password from MongoDB Atlas");
  console.log("2. IP whitelist in MongoDB Atlas - your current IP must be allowed");
  console.log("3. Network connectivity - ensure you can reach MongoDB Atlas servers");
  console.log("4. User permissions - the provided user must have appropriate database access");
}

testConnection().catch(console.error); 