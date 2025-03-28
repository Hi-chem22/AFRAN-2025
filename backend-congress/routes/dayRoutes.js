const express = require('express');
const router = express.Router();
const { 
  addDay, 
  getDays, 
  getDayById,
  getDayByNumber,
  updateDay, 
  deleteDay,
  addRoomToDay,
  removeRoomFromDay
} = require('../controllers/dayController');

// Routes pour les jours
router.post('/', addDay);
router.get('/', getDays);
router.get('/:id', getDayById);
router.get('/number/:number', getDayByNumber);
router.put('/:id', updateDay);
router.delete('/:id', deleteDay);

// Routes pour gérer la relation entre jours et salles
router.post('/:dayId/rooms/:roomId', addRoomToDay);
router.delete('/:dayId/rooms/:roomId', removeRoomFromDay);

module.exports = router; 