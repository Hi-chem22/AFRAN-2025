const mongoose = require('mongoose');

const adSchema = new mongoose.Schema({
  content: String,
  imageUrl: String,
  linkUrl: String,
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Ad = mongoose.model('Ad', adSchema);
module.exports = Ad; 