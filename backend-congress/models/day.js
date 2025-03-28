const mongoose = require('mongoose');

const daySchema = new mongoose.Schema({
  number: {
    type: Number,
    required: true,
    min: 1,
    max: 10,
    unique: true
  },
  date: {
    type: Date,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  description: String,
  rooms: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Room'
  }],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Day = mongoose.model('Day', daySchema);
module.exports = Day; 