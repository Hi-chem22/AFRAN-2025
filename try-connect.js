const { MongoClient, ServerApiVersion } = require('mongodb');

// Original connection string from MongoDB Atlas dashboard
// Password might have special characters, so there are two options to try:

// OPTION 1: URL-encode the password
const username = "hichem";
const password = encodeURIComponent("KEKC5B6EumkFl5cT"); // URL-encoded
const uri1 = `mongodb+srv://${username}:${password}@cluster0.pt98b.mongodb.net/?appName=Cluster0`;

// OPTION 2: Use password without angle brackets
const uri2 = "mongodb+srv://hichem:KEKC5B6EumkFl5cT@cluster0.pt98b.mongodb.net/?appName=Cluster0";

// OPTION 3: Try with username "admin"
const uri3 = "mongodb+srv://admin:KEKC5B6EumkFl5cT@cluster0.pt98b.mongodb.net/?appName=Cluster0";

// Function to test connection with a given URI
async function testConnection(uri, description) {
  console.log(`\n----- Testing ${description} -----`);
  
  const client = new MongoClient(uri, {
    serverApi: {
      version: ServerApiVersion.v1,
      strict: true,
      deprecationErrors: true,
    }
  });
  
  try {
    console.log("Connecting to MongoDB...");
    await client.connect();
    await client.db("admin").command({ ping: 1 });
    console.log("✅ SUCCESS: Connected to MongoDB!");
    return true;
  } catch (err) {
    console.error("❌ FAILED:", err.message);
    if (err.code) {
      console.error("Error code:", err.code);
    }
    return false;
  } finally {
    await client.close();
  }
}

// Test all connection options
async function run() {
  console.log("========================================");
  console.log("TESTING MONGODB CONNECTION OPTIONS");
  console.log("========================================");
  
  let success = false;
  
  // Try option 1: URL-encoded password
  success = await testConnection(uri1, "URL-encoded password") || success;
  
  // Try option 2: Password as-is
  success = await testConnection(uri2, "Password as-is") || success;
  
  // Try option 3: With username "admin"
  success = await testConnection(uri3, "Username 'admin'") || success;
  
  console.log("\n========================================");
  if (success) {
    console.log("✅ Successfully connected with at least one option!");
  } else {
    console.log("❌ All connection attempts failed");
    console.log("\nPlease verify the following:");
    console.log("1. IP WHITELISTING: Make sure your IP address is whitelisted in MongoDB Atlas");
    console.log("2. CREDENTIALS: Verify username and password in MongoDB Atlas");
    console.log("3. NETWORK: Check if there are any network restrictions");
    console.log("4. CLUSTER STATUS: Ensure your MongoDB Atlas cluster is active");
  }
  console.log("========================================");
}

run().catch(console.error); 