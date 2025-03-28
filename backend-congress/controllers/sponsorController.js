const { Sponsor } = require('../models');

// Ajouter un nouveau sponsor
const addSponsor = async (req, res) => {
  try {
    const sponsor = new Sponsor(req.body);
    await sponsor.save();
    res.status(201).json(sponsor);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer tous les sponsors
const getSponsors = async (req, res) => {
  try {
    const sponsors = await Sponsor.find();
    res.status(200).json(sponsors);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer un sponsor par ID
const getSponsorById = async (req, res) => {
  try {
    const sponsor = await Sponsor.findById(req.params.id);
    
    if (!sponsor) {
      return res.status(404).json({ error: 'Sponsor not found' });
    }
    
    res.status(200).json(sponsor);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Mettre à jour un sponsor
const updateSponsor = async (req, res) => {
  try {
    const sponsor = await Sponsor.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!sponsor) {
      return res.status(404).json({ error: 'Sponsor not found' });
    }
    
    res.status(200).json(sponsor);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Supprimer un sponsor
const deleteSponsor = async (req, res) => {
  try {
    const sponsor = await Sponsor.findByIdAndDelete(req.params.id);
    
    if (!sponsor) {
      return res.status(404).json({ error: 'Sponsor not found' });
    }
    
    res.status(200).json({ message: 'Sponsor deleted successfully' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

module.exports = {
  addSponsor,
  getSponsors,
  getSponsorById,
  updateSponsor,
  deleteSponsor
}; 