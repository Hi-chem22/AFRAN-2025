const { MongoClient } = require('mongodb');

// Try with additional password variations and different formats
const credentialsToTry = [
  // Original password formatted differently
  { username: "hichem", password: "KEKC5B6EumkFl5cT", desc: "Standard password" },
  { username: "hichem", password: "<KEKC5B6EumkFl5cT>", desc: "With angle brackets" },
  
  // Check if there was a typo in the password
  { username: "hichem", password: "KEKC5B6EumkFI5cT", desc: "Using I instead of l" },
  { username: "hichem", password: "KEKC5B6EumkF15cT", desc: "Using 1 instead of l" },
  
  // Test with no URL encoding but directly in connection string
  { connectionString: "mongodb+srv://hichem:KEKC5B6EumkFl5cT@cluster0.pt98b.mongodb.net/", desc: "Direct string" },
  
  // Try with connection string directly to shards
  { connectionString: "mongodb://hichem:KEKC5B6EumkFl5cT@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin", desc: "Direct shards" }
];

async function testConnections() {
  console.log("TESTING MULTIPLE CONNECTION METHODS\n");
  
  for (const cred of credentialsToTry) {
    let uri;
    
    if (cred.connectionString) {
      uri = cred.connectionString;
      console.log(`Testing direct connection string [${cred.desc}]`);
    } else {
      // Don't URL encode the password - try raw
      uri = `mongodb+srv://${cred.username}:${cred.password}@cluster0.pt98b.mongodb.net/`;
      console.log(`Testing credentials: username=${cred.username}, password=*** [${cred.desc}]`);
    }
    
    const client = new MongoClient(uri, { connectTimeoutMS: 5000 });
    
    try {
      console.log("Connecting...");
      await client.connect();
      console.log("✅ CONNECTION SUCCESSFUL!\n");
      console.log("Working connection string (hiding password):");
      console.log(uri.replace(/:[^:]*@/, ":****@"));
      await client.close();
      return true;
    } catch (err) {
      console.log(`❌ Connection failed: ${err.message}\n`);
    } finally {
      try { await client.close(); } catch {}
    }
  }
  
  return false;
}

// Try to connect with all variations
testConnections().then(success => {
  if (!success) {
    console.log("\n==================================");
    console.log("ALL CONNECTION ATTEMPTS FAILED");
    console.log("==================================");
    console.log("CRITICAL CHECKLIST:");
    console.log("1. Confirm your MongoDB Atlas password (it might have been changed)");
    console.log("2. Try creating a new database user in MongoDB Atlas:");
    console.log("   - Go to Security > Database Access");
    console.log("   - Click 'Add New Database User'");
    console.log("   - Use a simple alphanumeric password with no special characters");
    console.log("3. Verify there are no network restrictions in your environment");
    console.log("4. Try connecting from a different network if possible");
  }
}); 