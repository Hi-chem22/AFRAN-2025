const express = require('express');
const router = express.Router();
const { 
  addSubsession, 
  getSubsessions, 
  getSubsessionById,
  getSubsessionsBySession,
  updateSubsession,
  deleteSubsession,
  addSubsubsession
} = require('../controllers/subsessionController');

// Routes pour les sous-sessions
router.post('/', addSubsession);
router.get('/', getSubsessions);
router.get('/:id', getSubsessionById);
router.get('/session/:sessionId', getSubsessionsBySession);
router.put('/:id', updateSubsession);
router.delete('/:id', deleteSubsession);

// Routes pour les sous-sous-sessions
router.post('/:subsessionId/subsubsessions', addSubsubsession);

module.exports = router; 