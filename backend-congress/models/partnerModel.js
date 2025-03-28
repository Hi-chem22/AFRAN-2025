const mongoose = require('mongoose');

const partnerSchema = mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Le nom du partenaire est requis'],
      trim: true
    },
    description: {
      type: String,
      trim: true
    },
    url: {
      type: String,
      trim: true
    },
    logoUrl: {
      type: String,
      trim: true
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

module.exports = mongoose.model('Partner', partnerSchema);
