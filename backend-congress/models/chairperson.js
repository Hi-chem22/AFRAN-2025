const mongoose = require('mongoose');

const chairpersonSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  title: {
    type: String,
    trim: true
  },
  institution: {
    type: String,
    trim: true
  },
  bio: {
    type: String
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Chairperson = mongoose.model('Chairperson', chairpersonSchema);
module.exports = Chairperson; 