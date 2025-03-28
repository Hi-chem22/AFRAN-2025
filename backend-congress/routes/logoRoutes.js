const express = require('express');
const router = express.Router();
const { 
  getActiveLogo, 
  createLogo, 
  updateLogoStatus, 
  getAllLogos 
} = require('../controllers/logoController');

// Public routes
router.route('/').get(getActiveLogo).post(createLogo);
router.route('/all').get(getAllLogos);
router.route('/:id').put(updateLogoStatus);

module.exports = router; 