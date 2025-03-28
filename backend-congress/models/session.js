const mongoose = require('mongoose');

// Define a schema for subsubsession text representation
const subsubsessionTextSchema = new mongoose.Schema({
  title: String,
  startTime: String,
  endTime: String,
  duration: String,
  speakerIds: [String],
  description: String
}, { _id: false });

// Define a schema for subsession text representation
const subsessionTextSchema = new mongoose.Schema({
  title: String,
  startTime: String,
  endTime: String,
  duration: String,
  speakerIds: [String],
  description: String,
  subsubsessions: [subsubsessionTextSchema]
}, { _id: false });

const sessionSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  room: String,
  roomId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Room'
  },
  day: Number,
  dayId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Day'
  },
  startTime: {
    type: String,
    required: true
  },
  endTime: {
    type: String,
    required: true
  },
  description: String,
  // Session type (e.g., Regular, Lunch Symposium, etc.)
  type: {
    type: String,
    default: 'Regular'
  },
  // Laboratory/company logo URL for lunch symposia
  labLogoUrl: {
    type: String,
    default: ''
  },
  // New fields for text representation
  chairpersons: String,
  subsessionTexts: [subsessionTextSchema],
  // Keep original fields for backward compatibility
  speakers: [{ 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Speaker' 
  }],
  subsessions: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Subsession'
  }],
  chairpersonRefs: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Chairperson'
  }],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Session = mongoose.model('Session', sessionSchema);
module.exports = Session; 