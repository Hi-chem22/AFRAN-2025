const { MongoClient, ServerApiVersion } = require('mongodb');

// EXPLANATION:
// The original connection string showed the password as <KEKC5B6EumkFl5cT>
// Let's try various interpretations of this password format:

// Password variations to test
const passwordVariations = [
  "KEKC5B6EumkFl5cT",         // Without angle brackets
  "<KEKC5B6EumkFl5cT>",       // With angle brackets (literal interpretation)
  "KEKC5B6EumkFl5cT>",        // Without opening bracket
  "<KEKC5B6EumkFl5cT",        // Without closing bracket
  "KEKC5B6Eumk",              // Shorter version (truncated)
  "KEKC-5B6-Eumk-Fl5cT",      // With hyphens
  "kekc5b6eumkfl5ct"          // Lowercase
];

// Test all password variations
async function testPasswordVariations() {
  console.log("TESTING MONGODB CONNECTION WITH PASSWORD VARIATIONS");
  console.log("===================================================");
  
  // Username variations to try
  const usernames = ["hichem", "admin"];
  
  // Track if any connection succeeded
  let anyConnectionSucceeded = false;
  
  // Try each combination of username and password
  for (const username of usernames) {
    console.log(`\n----- Testing with username: "${username}" -----`);
    
    for (const [index, pwd] of passwordVariations.entries()) {
      // Create encoded password version
      const encodedPwd = encodeURIComponent(pwd);
      
      // Build connection string
      const uri = `mongodb+srv://${username}:${encodedPwd}@cluster0.pt98b.mongodb.net/?appName=Cluster0`;
      
      console.log(`\nTesting password variation ${index + 1}: "${pwd.replace(/./g, '*')}"`);
      console.log(`Password length: ${pwd.length} characters`);
      
      const client = new MongoClient(uri, {
        serverApi: {
          version: ServerApiVersion.v1,
          strict: true,
          deprecationErrors: true,
        },
        connectTimeoutMS: 5000 // Short timeout for faster testing
      });
      
      try {
        await client.connect();
        await client.db("admin").command({ ping: 1 });
        console.log("✅ CONNECTION SUCCESSFUL!");
        console.log(`Working credentials: username="${username}", password="${pwd.replace(/./g, '*')}"`);
        
        // Store working combination
        anyConnectionSucceeded = true;
        
        // Provide connection string for future use
        console.log("\nWorking connection string (with password masked):");
        console.log(`mongodb+srv://${username}:****@cluster0.pt98b.mongodb.net/?appName=Cluster0`);
        
        await client.close();
        return true; // Exit once we find a working combination
      } catch (err) {
        console.log(`❌ Connection failed: ${err.message}`);
      } finally {
        await client.close();
      }
    }
  }
  
  return anyConnectionSucceeded;
}

// Main function
async function main() {
  try {
    const success = await testPasswordVariations();
    
    console.log("\n===================================================");
    if (!success) {
      console.log("❌ ALL CONNECTION ATTEMPTS FAILED");
      console.log("\nIMPORTANT TROUBLESHOOTING STEPS:");
      console.log("1. Check IP whitelisting - Your current IP must be allowed in MongoDB Atlas");
      console.log("2. Verify credentials directly in MongoDB Atlas dashboard");
      console.log("3. Ensure your cluster is running and accessible");
      console.log("4. Check network connectivity to MongoDB Atlas");
    }
    console.log("===================================================");
  } catch (err) {
    console.error("Error during testing:", err);
  }
}

// Run the script
main().catch(console.error); 