const { Ad } = require('../models');

// Ajouter une nouvelle publicité
const addAd = async (req, res) => {
  try {
    const ad = new Ad(req.body);
    await ad.save();
    res.status(201).json(ad);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer toutes les publicités
const getAds = async (req, res) => {
  try {
    const ads = await Ad.find();
    res.status(200).json(ads);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer une publicité par ID
const getAdById = async (req, res) => {
  try {
    const ad = await Ad.findById(req.params.id);
    
    if (!ad) {
      return res.status(404).json({ error: 'Ad not found' });
    }
    
    res.status(200).json(ad);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Mettre à jour une publicité
const updateAd = async (req, res) => {
  try {
    const ad = await Ad.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!ad) {
      return res.status(404).json({ error: 'Ad not found' });
    }
    
    res.status(200).json(ad);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Supprimer une publicité
const deleteAd = async (req, res) => {
  try {
    const ad = await Ad.findByIdAndDelete(req.params.id);
    
    if (!ad) {
      return res.status(404).json({ error: 'Ad not found' });
    }
    
    res.status(200).json({ message: 'Ad deleted successfully' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

module.exports = {
  addAd,
  getAds,
  getAdById,
  updateAd,
  deleteAd
}; 