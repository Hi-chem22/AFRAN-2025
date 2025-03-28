const { Room } = require('../models');

// Ajouter une nouvelle salle
const addRoom = async (req, res) => {
  try {
    const room = new Room(req.body);
    await room.save();
    res.status(201).json(room);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer toutes les salles
const getRooms = async (req, res) => {
  try {
    const rooms = await Room.find();
    res.status(200).json(rooms);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer une salle par ID
const getRoomById = async (req, res) => {
  try {
    const room = await Room.findById(req.params.id);
    
    if (!room) {
      return res.status(404).json({ error: 'Room not found' });
    }
    
    res.status(200).json(room);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Mettre à jour une salle
const updateRoom = async (req, res) => {
  try {
    const room = await Room.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!room) {
      return res.status(404).json({ error: 'Room not found' });
    }
    
    res.status(200).json(room);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Supprimer une salle
const deleteRoom = async (req, res) => {
  try {
    const room = await Room.findByIdAndDelete(req.params.id);
    
    if (!room) {
      return res.status(404).json({ error: 'Room not found' });
    }
    
    res.status(200).json({ message: 'Room deleted successfully' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

module.exports = {
  addRoom,
  getRooms,
  getRoomById,
  updateRoom,
  deleteRoom
}; 