const express = require('express');
const router = express.Router();
const { 
  addAd, 
  getAds, 
  getAdById, 
  updateAd, 
  deleteAd 
} = require('../controllers/adController');

// Routes pour les publicités
router.post('/', addAd);
router.get('/', getAds);
router.get('/:id', getAdById);
router.put('/:id', updateAd);
router.delete('/:id', deleteAd);

module.exports = router; 