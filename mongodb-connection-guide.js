/**
 * MONGODB CONNECTION GUIDE
 * 
 * Based on our connection attempts, it seems there might be an issue with:
 * 1. The cluster name or hostname
 * 2. The username/password combination
 * 3. IP address whitelisting in MongoDB Atlas
 * 
 * RECOMMENDED STEPS:
 * 
 * 1. Log in to your MongoDB Atlas dashboard at https://cloud.mongodb.com
 * 
 * 2. Find your cluster and click "Connect"
 * 
 * 3. Choose "Connect your application" and copy the exact connection string
 *    It should look something like:
 *    mongodb+srv://<username>:<password>@cluster0.abcde.mongodb.net/?retryWrites=true&w=majority
 * 
 * 4. Make sure to whitelist your current IP address in the Atlas dashboard
 *    (Network Access → Add IP Address → Add Current IP Address)
 * 
 * 5. Use the connection string below, replacing values in angle brackets
 */

const { MongoClient } = require('mongodb');

// Copy the full connection string from your MongoDB Atlas dashboard
// Make sure to replace <username>, <password>, and <clusterUrl> with actual values
// Example: mongodb+srv://myUsername:myPassword@mycluster.ab123.mongodb.net/
const connectionString = "mongodb+srv://<username>:<password>@<clusterUrl>/?retryWrites=true&w=majority";

// Replace <dbName> with your actual database name
const dbName = "<dbName>";

// Create a MongoDB client
const client = new MongoClient(connectionString);

async function connectToMongoDB() {
  try {
    // Connect to MongoDB
    console.log("Connecting to MongoDB Atlas...");
    await client.connect();
    console.log("✅ Successfully connected to MongoDB Atlas!");
    
    // Get the database
    const db = client.db(dbName);
    
    // List collections
    console.log(`\nListing collections in ${dbName}:`);
    const collections = await db.listCollections().toArray();
    
    if (collections.length === 0) {
      console.log("No collections found in this database.");
    } else {
      collections.forEach(collection => {
        console.log(` - ${collection.name}`);
      });
    }
    
  } catch (err) {
    console.error("❌ Connection failed:", err);
  } finally {
    // Close the connection
    await client.close();
    console.log("\nMongoDB connection closed");
  }
}

// Uncomment the line below to run the connection test
// connectToMongoDB().catch(console.error);

/**
 * IMPORTANT: If you're using the original format:
 * 
 * mongosh "mongodb+srv://admin:<KEKC5B6EumkFl5cT>@congresscluster.mongodb.net/congressDB"
 * 
 * Try these modifications:
 * 
 * 1. Remove angle brackets around the password:
 *    mongosh "mongodb+srv://admin:KEKC5B6EumkFl5cT@congresscluster.mongodb.net/congressDB"
 * 
 * 2. If that doesn't work, verify the exact cluster name from your Atlas dashboard
 *
 * 3. Make sure the mongosh tool is installed. If not, install it with:
 *    npm install -g mongosh
 */ 