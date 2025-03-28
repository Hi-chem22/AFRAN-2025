/**
 * Example script demonstrating how to use the MongoDB utility module
 */

const mongodb = require('./mongodb-utils');

async function runExample() {
  try {
    // Connect to MongoDB
    await mongodb.connect();
    
    // Get a list of all collections
    console.log("\n--- Listing all collections ---");
    const collections = await mongodb.listCollections();
    collections.forEach(coll => console.log(` - ${coll.name}`));
    
    // Work with the "users" collection
    const collectionName = "users";
    
    // Find all users
    console.log("\n--- Finding all users ---");
    const users = await mongodb.find(collectionName);
    console.log(`Found ${users.length} users`);
    
    // Add a timestamp to user data
    if (users.length > 0) {
      console.log("\n--- Updating user ---");
      const firstUser = users[0];
      const updateResult = await mongodb.updateOne(
        collectionName,
        { _id: firstUser._id },
        { $set: { lastAccessed: new Date(), isActive: true } }
      );
      console.log(`Updated ${updateResult.modifiedCount} user`);
    }
    
    // Insert a new user if "Alice Williams" doesn't exist
    console.log("\n--- Checking for Alice Williams ---");
    const aliceExists = await mongodb.findOne(collectionName, { name: "Alice Williams" });
    
    if (!aliceExists) {
      console.log("Alice Williams not found, creating new user");
      const insertResult = await mongodb.insertOne(collectionName, {
        name: "Alice Williams",
        email: "alice@example.com",
        age: 28,
        createdAt: new Date()
      });
      console.log(`Inserted user with ID: ${insertResult.insertedId}`);
    } else {
      console.log("Alice Williams already exists");
    }
    
    // Find users by age range
    console.log("\n--- Finding users by age range ---");
    const youngUsers = await mongodb.find(collectionName, { age: { $lt: 30 } });
    console.log(`Found ${youngUsers.length} users under 30 years old`);
    
    // Print all users
    console.log("\n--- All users (limited data) ---");
    const allUsers = await mongodb.find(collectionName);
    allUsers.forEach(user => {
      console.log(` - ${user.name}, ${user.email}, Age: ${user.age}`);
    });
    
  } catch (err) {
    console.error("Error:", err);
  } finally {
    // Always close the connection when done
    await mongodb.close();
  }
}

// Run the example
runExample().catch(console.error); 