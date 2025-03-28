const mongoose = require('mongoose');

const videoSchema = mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Le titre de la vidéo est requis'],
      trim: true
    },
    description: {
      type: String,
      trim: true
    },
    url: {
      type: String,
      required: [true, 'L\'URL de la vidéo est requise'],
      trim: true
    },
    sessionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Session',
      required: false
    },
    thumbnailUrl: {
      type: String,
      trim: true
    },
    category: {
      type: String,
      trim: true,
      enum: ['presentation', 'interview', 'conference', 'workshop', 'other'],
      default: 'other'
    },
    duration: {
      type: String,
      trim: true
    },
    speaker: {
      type: String,
      trim: true
    },
    date: {
      type: Date,
      default: Date.now
    },
    featured: {
      type: Boolean,
      default: false
    },
    active: {
      type: Boolean,
      default: true
    },
    order: {
      type: Number,
      default: 0
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Video', videoSchema);
