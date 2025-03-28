const { MongoClient } = require('mongodb');

// Connection details
const username = "hichem";
const password = "40221326Hi";
const dbName = "AfranDB"; // Note: Database names are case-sensitive in MongoDB

// Connection URI
const uri = `mongodb://${username}:${password}@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin`;

// Create a MongoDB client
const client = new MongoClient(uri);

// Function to demonstrate basic MongoDB operations
async function runMongoOperations() {
  try {
    console.log("Connecting to MongoDB...");
    await client.connect();
    console.log("Connected successfully to MongoDB Atlas!\n");

    // Get reference to the database
    const db = client.db(dbName);
    
    // ===== EXAMPLE 1: CREATE A COLLECTION =====
    console.log("EXAMPLE 1: Creating a collection if it doesn't exist");
    const collectionName = "users";
    await db.createCollection(collectionName);
    console.log(`Collection '${collectionName}' created or already exists\n`);
    
    // ===== EXAMPLE 2: INSERT DOCUMENTS =====
    console.log("EXAMPLE 2: Inserting documents");
    
    // Insert a single document
    const singleInsertResult = await db.collection(collectionName).insertOne({
      name: "John Doe",
      email: "john@example.com",
      age: 30,
      createdAt: new Date()
    });
    console.log(`Inserted 1 document with ID: ${singleInsertResult.insertedId}\n`);
    
    // Insert multiple documents
    const multipleInsertResult = await db.collection(collectionName).insertMany([
      { name: "Jane Smith", email: "jane@example.com", age: 25, createdAt: new Date() },
      { name: "Bob Johnson", email: "bob@example.com", age: 35, createdAt: new Date() }
    ]);
    console.log(`Inserted ${multipleInsertResult.insertedCount} documents\n`);
    
    // ===== EXAMPLE 3: QUERY DOCUMENTS =====
    console.log("EXAMPLE 3: Querying documents");
    
    // Find all documents
    const allDocs = await db.collection(collectionName).find({}).toArray();
    console.log(`Found ${allDocs.length} documents in total`);
    
    // Find documents with a filter
    const filteredDocs = await db.collection(collectionName).find({ age: { $gt: 25 } }).toArray();
    console.log(`Found ${filteredDocs.length} documents with age greater than 25\n`);
    
    // ===== EXAMPLE 4: UPDATE DOCUMENTS =====
    console.log("EXAMPLE 4: Updating documents");
    
    // Update a single document
    const updateResult = await db.collection(collectionName).updateOne(
      { name: "John Doe" },
      { $set: { status: "active", lastUpdated: new Date() } }
    );
    console.log(`Updated ${updateResult.modifiedCount} document\n`);
    
    // ===== EXAMPLE 5: DELETE DOCUMENTS =====
    console.log("EXAMPLE 5: Deleting documents");
    
    // Delete a single document
    const deleteResult = await db.collection(collectionName).deleteOne({ name: "Bob Johnson" });
    console.log(`Deleted ${deleteResult.deletedCount} document\n`);
    
    // ===== EXAMPLE 6: LIST ALL COLLECTIONS =====
    console.log("EXAMPLE 6: Listing all collections");
    const collections = await db.listCollections().toArray();
    collections.forEach(collection => {
      console.log(` - ${collection.name}`);
    });
    
    console.log("\nMongoDB operations completed successfully!");
    
  } catch (err) {
    console.error("Error:", err);
  } finally {
    await client.close();
    console.log("MongoDB connection closed");
  }
}

// Run the MongoDB operations
runMongoOperations().catch(console.error); 