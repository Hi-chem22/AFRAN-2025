const mongoose = require('mongoose');

const speakerSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  country: String,
  flagUrl: String,    // URL du drapeau stocké sur le serveur
  bio: String,
  speakerImageUrl: String,    // URL de l'image du speaker stockée sur le serveur
  externalImageFlag: String,  // URL externe (comme Imgur) pour le drapeau
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Speaker = mongoose.model('Speaker', speakerSchema);
module.exports = Speaker; 