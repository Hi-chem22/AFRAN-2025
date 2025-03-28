const Logo = require('../models/logoModel');
const asyncHandler = require('express-async-handler');

// @desc    Get active logo
// @route   GET /api/logo
// @access  Public
const getActiveLogo = asyncHandler(async (req, res) => {
  const logo = await Logo.findOne({ isActive: true }).sort({ createdAt: -1 });
  
  if (!logo) {
    return res.status(404).json({ message: 'No active logo found' });
  }
  
  res.json(logo);
});

// @desc    Create new logo
// @route   POST /api/logo
// @access  Private (should be protected in production)
const createLogo = asyncHandler(async (req, res) => {
  const { logoUrl } = req.body;

  if (!logoUrl) {
    res.status(400);
    throw new Error('Logo URL is required');
  }

  const logo = await Logo.create({
    logoUrl,
    isActive: true
  });

  res.status(201).json(logo);
});

// @desc    Update logo status
// @route   PUT /api/logo/:id
// @access  Private (should be protected in production)
const updateLogoStatus = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { isActive } = req.body;

  const logo = await Logo.findById(id);

  if (!logo) {
    res.status(404);
    throw new Error('Logo not found');
  }

  logo.isActive = isActive;
  await logo.save();

  res.json(logo);
});

// @desc    Get all logos
// @route   GET /api/logo/all
// @access  Private (should be protected in production)
const getAllLogos = asyncHandler(async (req, res) => {
  const logos = await Logo.find().sort({ createdAt: -1 });
  res.json(logos);
});

module.exports = {
  getActiveLogo,
  createLogo,
  updateLogoStatus,
  getAllLogos
}; 