const mongoose = require('mongoose');

const sponsorSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  rank: {
    type: String,
    required: true,
    enum: ['Gold', 'Silver', 'Bronze', 'Platinum', 'Diamond'],
    default: 'Bronze'
  },
  imageUrl: {
    type: String,
    required: true,
    trim: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Sponsor = mongoose.model('Sponsor', sponsorSchema);
module.exports = Sponsor; 