const mongoose = require('mongoose');

// Modèle pour les sous-sous-sessions
const subsubsessionSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  startTime: String,
  endTime: String,
  description: String,
  speakers: [{ 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Speaker' 
  }]
});

// Modèle pour les sous-sessions
const subsessionSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  startTime: String,
  endTime: String,
  description: String,
  sessionId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Session'
  },
  speakers: [{ 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Speaker' 
  }],
  subsubsessions: [subsubsessionSchema],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Subsession = mongoose.model('Subsession', subsessionSchema);
module.exports = Subsession; 