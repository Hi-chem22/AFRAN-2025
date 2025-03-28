const express = require('express');
const router = express.Router();
const Partner = require('../models/partnerModel');

// @desc    Get all partners
// @route   GET /api/partners
// @access  Public
router.get('/', async (req, res) => {
  try {
    const partners = await Partner.find({});
    res.json(partners);
  } catch (error) {
    console.error('Error fetching partners:', error);
    res.status(500).json({ message: 'Erreur lors de la récupération des partenaires' });
  }
});

// @desc    Get single partner by ID
// @route   GET /api/partners/:id
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const partner = await Partner.findById(req.params.id);
    
    if (!partner) {
      return res.status(404).json({ message: 'Partenaire non trouvé' });
    }
    
    res.json(partner);
  } catch (error) {
    console.error('Error fetching partner:', error);
    res.status(500).json({ message: 'Erreur lors de la récupération du partenaire' });
  }
});

// @desc    Create new partner
// @route   POST /api/partners
// @access  Public (consider adding authentication for production)
router.post('/', async (req, res) => {
  try {
    const newPartner = new Partner(req.body);
    const savedPartner = await newPartner.save();
    res.status(201).json(savedPartner);
  } catch (error) {
    console.error('Error creating partner:', error);
    res.status(500).json({ message: 'Erreur lors de la création du partenaire' });
  }
});

// @desc    Update partner
// @route   PUT /api/partners/:id
// @access  Public (consider adding authentication for production)
router.put('/:id', async (req, res) => {
  try {
    const updatedPartner = await Partner.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!updatedPartner) {
      return res.status(404).json({ message: 'Partenaire non trouvé' });
    }
    
    res.json(updatedPartner);
  } catch (error) {
    console.error('Error updating partner:', error);
    res.status(500).json({ message: 'Erreur lors de la mise à jour du partenaire' });
  }
});

// @desc    Delete partner
// @route   DELETE /api/partners/:id
// @access  Public (consider adding authentication for production)
router.delete('/:id', async (req, res) => {
  try {
    const deletedPartner = await Partner.findByIdAndDelete(req.params.id);
    
    if (!deletedPartner) {
      return res.status(404).json({ message: 'Partenaire non trouvé' });
    }
    
    res.json({ message: 'Partenaire supprimé avec succès' });
  } catch (error) {
    console.error('Error deleting partner:', error);
    res.status(500).json({ message: 'Erreur lors de la suppression du partenaire' });
  }
});

module.exports = router;
