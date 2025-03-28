const express = require('express');
const router = express.Router();
const { 
  addRoom, 
  getRooms, 
  getRoomById, 
  updateRoom, 
  deleteRoom 
} = require('../controllers/roomController');

// Routes pour les salles
router.post('/', addRoom);
router.get('/', getRooms);
router.get('/:id', getRoomById);
router.put('/:id', updateRoom);
router.delete('/:id', deleteRoom);

module.exports = router; 