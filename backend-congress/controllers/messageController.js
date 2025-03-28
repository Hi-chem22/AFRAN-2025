const { Message } = require('../models');

// Ajouter un nouveau message
const addMessage = async (req, res) => {
  try {
    // Check if the request contains the welcomeMessage wrapper
    const messageData = req.body.welcomeMessage || req.body;
    
    // If this is a welcome message and marked as active, deactivate other messages
    if (messageData.isActive) {
      await Message.updateMany({}, { isActive: false });
    }

    // Handle author images if uploaded
    if (req.files && req.files.length > 0) {
      const authors = JSON.parse(messageData.authors || '[]');
      req.files.forEach((file, index) => {
        if (authors[index]) {
          authors[index].imageUrl = `/uploads/authors/${file.filename}`;
        }
      });
      messageData.authors = authors;
    }
    
    const message = new Message(messageData);
    await message.save();
    res.status(201).json(message);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer tous les messages
const getMessages = async (req, res) => {
  try {
    // Check if request is looking for active messages only
    const filter = req.query.active === 'true' ? { isActive: true } : {};
    const messages = await Message.find(filter);
    res.status(200).json(messages);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer un message par ID
const getMessageById = async (req, res) => {
  try {
    const message = await Message.findById(req.params.id);
    
    if (!message) {
      return res.status(404).json({ error: 'Message not found' });
    }
    
    res.status(200).json(message);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Mettre à jour un message
const updateMessage = async (req, res) => {
  try {
    // Check if the request contains the welcomeMessage wrapper
    const messageData = req.body.welcomeMessage || req.body;
    
    // If this is a welcome message and marked as active, deactivate other messages
    if (messageData.isActive) {
      await Message.updateMany({ _id: { $ne: req.params.id } }, { isActive: false });
    }

    // Handle author images if uploaded
    if (req.files && req.files.length > 0) {
      const authors = JSON.parse(messageData.authors || '[]');
      req.files.forEach((file, index) => {
        if (authors[index]) {
          authors[index].imageUrl = `/uploads/authors/${file.filename}`;
        }
      });
      messageData.authors = authors;
    }
    
    const message = await Message.findByIdAndUpdate(
      req.params.id,
      messageData,
      { new: true, runValidators: true }
    );
    
    if (!message) {
      return res.status(404).json({ error: 'Message not found' });
    }
    
    res.status(200).json(message);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Supprimer un message
const deleteMessage = async (req, res) => {
  try {
    const message = await Message.findByIdAndDelete(req.params.id);
    
    if (!message) {
      return res.status(404).json({ error: 'Message not found' });
    }
    
    res.status(200).json({ message: 'Message deleted successfully' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

module.exports = {
  addMessage,
  getMessages,
  getMessageById,
  updateMessage,
  deleteMessage
}; 