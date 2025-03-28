const mongoose = require('mongoose');

const logoSchema = new mongoose.Schema(
  {
    logoUrl: {
      type: String,
      required: [true, 'Logo URL is required'],
      trim: true,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Middleware to ensure only one active logo
logoSchema.pre('save', async function(next) {
  if (this.isActive) {
    // Find all other logos and set them to inactive
    await this.constructor.updateMany(
      { _id: { $ne: this._id } },
      { isActive: false }
    );
  }
  next();
});

const Logo = mongoose.model('Logo', logoSchema);

module.exports = Logo; 