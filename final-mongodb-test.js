/**
 * MongoDB Connection Testing Script
 * 
 * This script attempts multiple connection methods to MongoDB Atlas
 * and provides detailed error information for troubleshooting.
 */

const { MongoClient, ServerApiVersion } = require('mongodb');

// Connection details
const username = "admin";
const password = "KEKC5B6EumkFl5cT"; 
const encodedPassword = encodeURIComponent(password);
const clusterName = "congresscluster"; // Without .mongodb.net
const dbName = "afranDB";

// === CONNECTION STRINGS TO TEST ===

// 1. Standard SRV connection string (primary format recommended by MongoDB Atlas)
const srvConnectionString = `mongodb+srv://${username}:${encodedPassword}@${clusterName}.mongodb.net/${dbName}?retryWrites=true&w=majority`;

// 2. Direct connection without SRV lookup
const directConnectionString = `mongodb://${username}:${encodedPassword}@${clusterName}.mongodb.net:27017/${dbName}?ssl=true&authSource=admin&retryWrites=true&w=majority`;

// 3. Connection with replica set format (common Atlas pattern)
const replicaSetConnectionString = `mongodb://${username}:${encodedPassword}@${clusterName}-shard-00-00.mongodb.net:27017,${clusterName}-shard-00-01.mongodb.net:27017,${clusterName}-shard-00-02.mongodb.net:27017/${dbName}?ssl=true&replicaSet=atlas-cluster&authSource=admin&retryWrites=true&w=majority`;

// Client options - you may need to adjust these
const clientOptions = {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true
  },
  connectTimeoutMS: 30000
};

// === TEST FUNCTION ===
async function testConnection(connectionString, name) {
  console.log(`\n=== TESTING ${name} ===`);
  console.log(`Connection string: mongodb://${username}:****@${connectionString.split('@')[1]}`);
  
  const client = new MongoClient(connectionString, clientOptions);
  
  try {
    console.log("Connecting...");
    await client.connect();
    console.log("✅ CONNECTION SUCCESSFUL!");
    
    // Get database info
    console.log(`Accessing database: ${dbName}`);
    const db = client.db(dbName);
    
    // List collections
    const collections = await db.listCollections().toArray();
    if (collections.length === 0) {
      console.log("No collections found in this database.");
    } else {
      console.log("Collections:");
      collections.forEach(collection => {
        console.log(` - ${collection.name}`);
      });
    }
    
    return true;
  } catch (err) {
    console.error("❌ CONNECTION FAILED");
    console.error(`Error type: ${err.name}`);
    console.error(`Error message: ${err.message}`);
    
    if (err.code) {
      console.error(`Error code: ${err.code}`);
    }
    
    return false;
  } finally {
    await client.close();
    console.log(`Connection closed for ${name}`);
  }
}

// === MAIN FUNCTION ===
async function runTests() {
  console.log("==================================================");
  console.log("MONGODB CONNECTION TESTING");
  console.log("==================================================");
  console.log("Username: " + username);
  console.log("Database: " + dbName);
  console.log("Cluster name: " + clusterName);
  console.log("==================================================\n");
  
  let success = false;
  
  // Test SRV connection
  try {
    success = await testConnection(srvConnectionString, "STANDARD SRV CONNECTION") || success;
  } catch (e) {
    console.error("Error running SRV test:", e);
  }
  
  // Test direct connection
  try {
    success = await testConnection(directConnectionString, "DIRECT CONNECTION") || success;
  } catch (e) {
    console.error("Error running direct connection test:", e);
  }
  
  // Test replica set connection
  try {
    success = await testConnection(replicaSetConnectionString, "REPLICA SET CONNECTION") || success;
  } catch (e) {
    console.error("Error running replica set test:", e);
  }
  
  console.log("\n==================================================");
  if (success) {
    console.log("✅ AT LEAST ONE CONNECTION METHOD SUCCEEDED!");
  } else {
    console.log("❌ ALL CONNECTION METHODS FAILED");
    console.log("\nTROUBLESHOOTING STEPS:");
    console.log("1. Check MongoDB Atlas dashboard for correct connection string");
    console.log("2. Verify username and password");
    console.log("3. Ensure your IP address is whitelisted in Atlas Network Access");
    console.log("4. Confirm the cluster name is 'congresscluster'");
    console.log("5. Try using MongoDB Compass with the same connection string");
    console.log("6. Check your network connectivity to MongoDB Atlas servers");
  }
  console.log("==================================================");
}

// Run the tests
runTests().catch(console.error); 