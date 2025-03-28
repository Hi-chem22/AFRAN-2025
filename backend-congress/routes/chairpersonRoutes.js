const express = require('express');
const router = express.Router();
const { 
  addChairperson, 
  getChairpersons, 
  getChairpersonById, 
  updateChairperson, 
  deleteChairperson 
} = require('../controllers/chairpersonController');

// Routes pour les modérateurs
router.post('/', addChairperson);
router.get('/', getChairpersons);
router.get('/:id', getChairpersonById);
router.put('/:id', updateChairperson);
router.delete('/:id', deleteChairperson);

module.exports = router; 