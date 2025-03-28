const { Chairperson } = require('../models');

// Créer un nouveau modérateur
const addChairperson = async (req, res) => {
  try {
    const chairperson = new Chairperson(req.body);
    await chairperson.save();
    res.status(201).json(chairperson);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer tous les modérateurs
const getChairpersons = async (req, res) => {
  try {
    const chairpersons = await Chairperson.find().sort({ name: 1 });
    res.status(200).json(chairpersons);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer un modérateur par ID
const getChairpersonById = async (req, res) => {
  try {
    const chairperson = await Chairperson.findById(req.params.id);
    if (!chairperson) {
      return res.status(404).json({ error: 'Modérateur non trouvé' });
    }
    res.status(200).json(chairperson);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Mettre à jour un modérateur
const updateChairperson = async (req, res) => {
  try {
    const chairperson = await Chairperson.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    if (!chairperson) {
      return res.status(404).json({ error: 'Modérateur non trouvé' });
    }
    res.status(200).json(chairperson);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Supprimer un modérateur
const deleteChairperson = async (req, res) => {
  try {
    const chairperson = await Chairperson.findByIdAndDelete(req.params.id);
    if (!chairperson) {
      return res.status(404).json({ error: 'Modérateur non trouvé' });
    }
    res.status(200).json({ message: 'Modérateur supprimé avec succès' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

module.exports = {
  addChairperson,
  getChairpersons,
  getChairpersonById,
  updateChairperson,
  deleteChairperson
}; 