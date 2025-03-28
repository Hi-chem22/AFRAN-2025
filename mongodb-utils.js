/**
 * MongoDB Utility Module
 * A reusable module for MongoDB operations
 */

const { MongoClient } = require('mongodb');

// Connection details
const username = "hichem";
const password = "40221326Hi";
const dbName = "AfranDB"; 

// Connection URI
const uri = `mongodb://${username}:${password}@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin`;

// Create MongoDB client
const client = new MongoClient(uri);

/**
 * MongoDB Database class with utility methods
 */
class MongoDB {
  constructor() {
    this.client = client;
    this.db = null;
    this.connected = false;
  }

  /**
   * Connect to MongoDB
   * @returns {Promise<boolean>} Connection success status
   */
  async connect() {
    if (this.connected) return true;
    
    try {
      await this.client.connect();
      this.db = this.client.db(dbName);
      this.connected = true;
      console.log("Connected to MongoDB Atlas");
      return true;
    } catch (err) {
      console.error("MongoDB connection error:", err);
      throw err;
    }
  }

  /**
   * Close the MongoDB connection
   */
  async close() {
    if (this.connected) {
      await this.client.close();
      this.connected = false;
      console.log("MongoDB connection closed");
    }
  }

  /**
   * Get a collection
   * @param {string} collectionName - Name of the collection
   * @returns {Collection} MongoDB collection
   */
  collection(collectionName) {
    if (!this.connected) {
      throw new Error("Not connected to MongoDB. Call connect() first.");
    }
    return this.db.collection(collectionName);
  }

  /**
   * Create a new collection
   * @param {string} collectionName - Name of the collection to create
   * @returns {Promise<Collection>} The created collection
   */
  async createCollection(collectionName) {
    if (!this.connected) {
      throw new Error("Not connected to MongoDB. Call connect() first.");
    }
    
    try {
      return await this.db.createCollection(collectionName);
    } catch (err) {
      // If collection already exists, return the existing collection
      if (err.code === 48) {
        return this.db.collection(collectionName);
      }
      throw err;
    }
  }

  /**
   * List all collections in the database
   * @returns {Promise<Array>} Array of collection info objects
   */
  async listCollections() {
    if (!this.connected) {
      throw new Error("Not connected to MongoDB. Call connect() first.");
    }
    
    return await this.db.listCollections().toArray();
  }

  /**
   * Insert a single document into a collection
   * @param {string} collectionName - Name of the collection
   * @param {object} doc - Document to insert
   * @returns {Promise<object>} Result of the insertion
   */
  async insertOne(collectionName, doc) {
    return await this.collection(collectionName).insertOne(doc);
  }

  /**
   * Insert multiple documents into a collection
   * @param {string} collectionName - Name of the collection
   * @param {Array} docs - Array of documents to insert
   * @returns {Promise<object>} Result of the insertion
   */
  async insertMany(collectionName, docs) {
    return await this.collection(collectionName).insertMany(docs);
  }

  /**
   * Find documents in a collection
   * @param {string} collectionName - Name of the collection
   * @param {object} query - Query filter
   * @param {object} options - Query options
   * @returns {Promise<Array>} Array of documents
   */
  async find(collectionName, query = {}, options = {}) {
    return await this.collection(collectionName).find(query, options).toArray();
  }

  /**
   * Find a single document in a collection
   * @param {string} collectionName - Name of the collection
   * @param {object} query - Query filter
   * @returns {Promise<object>} Document or null
   */
  async findOne(collectionName, query) {
    return await this.collection(collectionName).findOne(query);
  }

  /**
   * Update a single document in a collection
   * @param {string} collectionName - Name of the collection
   * @param {object} filter - Query filter
   * @param {object} update - Update operations
   * @returns {Promise<object>} Result of the update
   */
  async updateOne(collectionName, filter, update) {
    return await this.collection(collectionName).updateOne(filter, update);
  }

  /**
   * Update multiple documents in a collection
   * @param {string} collectionName - Name of the collection
   * @param {object} filter - Query filter
   * @param {object} update - Update operations
   * @returns {Promise<object>} Result of the update
   */
  async updateMany(collectionName, filter, update) {
    return await this.collection(collectionName).updateMany(filter, update);
  }

  /**
   * Delete a single document from a collection
   * @param {string} collectionName - Name of the collection
   * @param {object} filter - Query filter
   * @returns {Promise<object>} Result of the deletion
   */
  async deleteOne(collectionName, filter) {
    return await this.collection(collectionName).deleteOne(filter);
  }

  /**
   * Delete multiple documents from a collection
   * @param {string} collectionName - Name of the collection
   * @param {object} filter - Query filter
   * @returns {Promise<object>} Result of the deletion
   */
  async deleteMany(collectionName, filter) {
    return await this.collection(collectionName).deleteMany(filter);
  }
}

// Export a singleton instance
module.exports = new MongoDB(); 