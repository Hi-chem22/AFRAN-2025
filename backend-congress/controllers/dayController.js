const { Day, Room } = require('../models');

// Ajouter un nouveau jour
const addDay = async (req, res) => {
  try {
    // Vérifier que les salles existent
    if (req.body.rooms && req.body.rooms.length > 0) {
      const roomsExist = await Room.countDocuments({
        _id: { $in: req.body.rooms }
      });
      
      if (roomsExist !== req.body.rooms.length) {
        return res.status(400).json({ error: 'Une ou plusieurs salles n\'existent pas' });
      }
    }
    
    const day = new Day(req.body);
    await day.save();
    
    // Retourner le jour avec les salles peuplées
    const populatedDay = await Day.findById(day._id).populate('rooms');
    
    res.status(201).json(populatedDay);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer tous les jours
const getDays = async (req, res) => {
  try {
    const days = await Day.find().populate('rooms');
    res.status(200).json(days);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer un jour par ID
const getDayById = async (req, res) => {
  try {
    const day = await Day.findById(req.params.id).populate('rooms');
    
    if (!day) {
      return res.status(404).json({ error: 'Jour non trouvé' });
    }
    
    res.status(200).json(day);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer un jour par numéro
const getDayByNumber = async (req, res) => {
  try {
    const day = await Day.findOne({ number: req.params.number }).populate('rooms');
    
    if (!day) {
      return res.status(404).json({ error: 'Jour non trouvé' });
    }
    
    res.status(200).json(day);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Mettre à jour un jour
const updateDay = async (req, res) => {
  try {
    // Vérifier que les salles existent si elles sont incluses dans la mise à jour
    if (req.body.rooms && req.body.rooms.length > 0) {
      const roomsExist = await Room.countDocuments({
        _id: { $in: req.body.rooms }
      });
      
      if (roomsExist !== req.body.rooms.length) {
        return res.status(400).json({ error: 'Une ou plusieurs salles n\'existent pas' });
      }
    }
    
    const day = await Day.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('rooms');
    
    if (!day) {
      return res.status(404).json({ error: 'Jour non trouvé' });
    }
    
    res.status(200).json(day);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Supprimer un jour
const deleteDay = async (req, res) => {
  try {
    const day = await Day.findByIdAndDelete(req.params.id);
    
    if (!day) {
      return res.status(404).json({ error: 'Jour non trouvé' });
    }
    
    res.status(200).json({ message: 'Jour supprimé avec succès' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Ajouter une salle à un jour
const addRoomToDay = async (req, res) => {
  try {
    const { dayId, roomId } = req.params;
    
    // Vérifier que la salle existe
    const room = await Room.findById(roomId);
    if (!room) {
      return res.status(404).json({ error: 'Salle non trouvée' });
    }
    
    // Ajouter la salle au jour s'il n'existe pas déjà
    const day = await Day.findByIdAndUpdate(
      dayId,
      { $addToSet: { rooms: roomId } },
      { new: true, runValidators: true }
    ).populate('rooms');
    
    if (!day) {
      return res.status(404).json({ error: 'Jour non trouvé' });
    }
    
    res.status(200).json(day);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Supprimer une salle d'un jour
const removeRoomFromDay = async (req, res) => {
  try {
    const { dayId, roomId } = req.params;
    
    const day = await Day.findByIdAndUpdate(
      dayId,
      { $pull: { rooms: roomId } },
      { new: true }
    ).populate('rooms');
    
    if (!day) {
      return res.status(404).json({ error: 'Jour non trouvé' });
    }
    
    res.status(200).json(day);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

module.exports = {
  addDay,
  getDays,
  getDayById,
  getDayByNumber,
  updateDay,
  deleteDay,
  addRoomToDay,
  removeRoomFromDay
}; 