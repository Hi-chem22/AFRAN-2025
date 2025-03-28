const { Speaker } = require('../models');
const fs = require('fs');
const path = require('path');
const XLSX = require('xlsx');

// Ajouter un nouvel intervenant
const addSpeaker = async (req, res) => {
  try {
    const speakerData = { ...req.body };
    
    // Gérer les URLs d'images directes depuis le body
    // Si flagUrl est fourni directement (Postman)
    if (speakerData.flagUrl && speakerData.flagUrl.startsWith('http')) {
      // Conserver l'URL directement dans flagUrl
      // Pas besoin de modification car le schema accepte déjà flagUrl
    }
    
    // Si speakerImageUrl est fourni directement (Postman)
    if (speakerData.speakerImageUrl && speakerData.speakerImageUrl.startsWith('http')) {
      // Conserver l'URL directement dans speakerImageUrl
      // Pas besoin de modification car le schema accepte déjà speakerImageUrl
    }
    
    // Si imageFlag est une URL externe (comme Imgur), la conserver
    if (speakerData.imageFlag && speakerData.imageFlag.startsWith('http')) {
      speakerData.externalImageFlag = speakerData.imageFlag;
      delete speakerData.imageFlag; // Pour éviter la confusion
    }
    
    // Si des fichiers ont été uploadés
    if (req.files) {
      // Gérer le drapeau (imageFlag)
      if (req.files.imageFlag && req.files.imageFlag.length > 0) {
        speakerData.flagUrl = `/uploads/flags/${req.files.imageFlag[0].filename}`;
      }
      
      // Gérer l'image du speaker
      if (req.files.image && req.files.image.length > 0) {
        speakerData.speakerImageUrl = `/uploads/speakers/${req.files.image[0].filename}`;
      }
    }
    
    // Afficher le speakerData pour déboguer
    console.log("Speaker data to save:", speakerData);
    
    const speaker = new Speaker(speakerData);
    await speaker.save();
    
    res.status(201).json(speaker);
  } catch (err) {
    console.error("Error saving speaker:", err);
    res.status(400).json({ error: err.message });
  }
};

// Récupérer tous les intervenants
const getSpeakers = async (req, res) => {
  try {
    const speakers = await Speaker.find();
    res.status(200).json(speakers);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer un intervenant par ID
const getSpeakerById = async (req, res) => {
  try {
    const speaker = await Speaker.findById(req.params.id);
    
    if (!speaker) {
      return res.status(404).json({ error: 'Speaker not found' });
    }
    
    res.status(200).json(speaker);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer l'image du drapeau d'un intervenant
const getSpeakerFlagImage = async (req, res) => {
  try {
    const speaker = await Speaker.findById(req.params.id, {
      'flagImage.data': 0, 
      'speakerImage.data': 0
    });
    
    if (!speaker || !speaker.flagImage || !speaker.flagImage.data) {
      return res.status(404).json({ error: 'Flag image not found' });
    }
    
    res.set('Content-Type', speaker.flagImage.contentType);
    res.send(speaker.flagImage.data);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Récupérer l'image du speaker
const getSpeakerImage = async (req, res) => {
  try {
    const speaker = await Speaker.findById(req.params.id, {
      'speakerImage.data': 0
    });
    
    if (!speaker || !speaker.speakerImage || !speaker.speakerImage.data) {
      return res.status(404).json({ error: 'Speaker image not found' });
    }
    
    res.set('Content-Type', speaker.speakerImage.contentType);
    res.send(speaker.speakerImage.data);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Mettre à jour un intervenant
const updateSpeaker = async (req, res) => {
  try {
    const speakerData = { ...req.body };
    const oldSpeaker = await Speaker.findById(req.params.id);
    
    if (!oldSpeaker) {
      return res.status(404).json({ error: 'Speaker not found' });
    }
    
    // Si imageFlag est une URL externe (comme Imgur), la conserver
    if (speakerData.imageFlag && speakerData.imageFlag.startsWith('http')) {
      speakerData.externalImageFlag = speakerData.imageFlag;
      delete speakerData.imageFlag; // Pour éviter la confusion
    }
    
    // Si des fichiers ont été uploadés
    if (req.files) {
      // Gérer le drapeau (imageFlag)
      if (req.files.imageFlag && req.files.imageFlag.length > 0) {
        // Supprimer l'ancien fichier de drapeau s'il existe
        if (oldSpeaker.flagUrl) {
          const oldFlagPath = path.join(__dirname, '..', oldSpeaker.flagUrl);
          if (fs.existsSync(oldFlagPath)) {
            fs.unlinkSync(oldFlagPath);
          }
        }
        
        speakerData.flagUrl = `/uploads/flags/${req.files.imageFlag[0].filename}`;
      }
      
      // Gérer l'image du speaker
      if (req.files.image && req.files.image.length > 0) {
        // Supprimer l'ancienne image s'il existe
        if (oldSpeaker.speakerImageUrl) {
          const oldImagePath = path.join(__dirname, '..', oldSpeaker.speakerImageUrl);
          if (fs.existsSync(oldImagePath)) {
            fs.unlinkSync(oldImagePath);
          }
        }
        
        speakerData.speakerImageUrl = `/uploads/speakers/${req.files.image[0].filename}`;
      }
    }
    
    // Afficher le speakerData pour déboguer
    console.log("Speaker data to update:", speakerData);
    
    const speaker = await Speaker.findByIdAndUpdate(
      req.params.id,
      speakerData,
      { new: true, runValidators: true }
    );
    
    if (!speaker) {
      return res.status(404).json({ error: 'Speaker not found' });
    }
    
    res.status(200).json(speaker);
  } catch (err) {
    console.error("Error updating speaker:", err);
    res.status(400).json({ error: err.message });
  }
};

// Supprimer un intervenant
const deleteSpeaker = async (req, res) => {
  try {
    const speaker = await Speaker.findById(req.params.id);
    
    if (!speaker) {
      return res.status(404).json({ error: 'Speaker not found' });
    }
    
    // Supprimer le fichier de drapeau si existant
    if (speaker.flagUrl) {
      const flagPath = path.join(__dirname, '..', speaker.flagUrl);
      if (fs.existsSync(flagPath)) {
        fs.unlinkSync(flagPath);
      }
    }
    
    // Supprimer l'image du speaker si existante
    if (speaker.speakerImageUrl) {
      const imagePath = path.join(__dirname, '..', speaker.speakerImageUrl);
      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath);
      }
    }
    
    await Speaker.findByIdAndDelete(req.params.id);
    
    res.status(200).json({ message: 'Speaker deleted successfully' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Importer des intervenants depuis un fichier Excel
const importSpeakersFromExcel = async (req, res) => {
  try {
    console.log('Import speakers from Excel request received');
    console.log('Request file:', req.file ? 'File present' : 'No file in req.file');
    
    // Check if file was uploaded
    if (!req.file) {
      console.log('No file uploaded in req.file');
      return res.status(400).json({ message: 'No file uploaded' });
    }
    
    console.log(`File uploaded: ${req.file.path}`);
    console.log(`File details: ${JSON.stringify({
      fieldname: req.file.fieldname,
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size
    })}`);
    
    // Read the Excel file
    const workbook = XLSX.readFile(req.file.path);
    console.log('Excel file read successfully');
    console.log(`Available sheets: ${workbook.SheetNames.join(', ')}`);
    
    // Check if Speakers sheet exists
    if (!workbook.SheetNames.includes('Speakers')) {
      return res.status(400).json({ message: 'Excel file must contain a "Speakers" sheet' });
    }
    
    const speakersSheet = workbook.Sheets['Speakers'];
    const speakers = XLSX.utils.sheet_to_json(speakersSheet);
    
    if (speakers.length === 0) {
      return res.status(400).json({ message: 'No speakers found in Excel file' });
    }
    
    console.log(`Found ${speakers.length} speakers in Excel file`);
    console.log(`Sample speaker data: ${JSON.stringify(speakers[0])}`);
    
    // Process speakers
    const processedSpeakers = [];
    let created = 0;
    let updated = 0;
    let errors = 0;
    
    for (const speakerData of speakers) {
      try {
        console.log(`Processing speaker: ${JSON.stringify(speakerData)}`);
        
        if (!speakerData.name) {
          console.log('Speaker name is required but not provided. Skipping record.');
          errors++;
          continue;
        }
        
        // Prepare speaker object
        const speakerObj = {
          name: speakerData.name,
          country: speakerData.country || '',
          bio: speakerData.bio || '',
          flagUrl: speakerData.flagUrl || '',
          speakerImageUrl: speakerData.speakerImageUrl || '',
          externalImageFlag: speakerData.externalImageFlag || ''
        };
        
        // Check if speaker already exists by name
        let existingSpeaker = null;
        if (speakerData._id) {
          existingSpeaker = await Speaker.findById(speakerData._id);
        }
        
        if (!existingSpeaker) {
          existingSpeaker = await Speaker.findOne({ name: speakerData.name });
        }
        
        if (existingSpeaker) {
          // Update existing speaker
          console.log(`Updating existing speaker: ${existingSpeaker.name}`);
          
          // Don't overwrite URLs if they exist in database and not in Excel
          if (!speakerObj.flagUrl && existingSpeaker.flagUrl) {
            speakerObj.flagUrl = existingSpeaker.flagUrl;
          }
          
          if (!speakerObj.speakerImageUrl && existingSpeaker.speakerImageUrl) {
            speakerObj.speakerImageUrl = existingSpeaker.speakerImageUrl;
          }
          
          if (!speakerObj.externalImageFlag && existingSpeaker.externalImageFlag) {
            speakerObj.externalImageFlag = existingSpeaker.externalImageFlag;
          }
          
          const updatedSpeaker = await Speaker.findByIdAndUpdate(
            existingSpeaker._id,
            speakerObj,
            { new: true, runValidators: true }
          );
          
          processedSpeakers.push(updatedSpeaker);
          updated++;
        } else {
          // Create new speaker
          console.log(`Creating new speaker: ${speakerData.name}`);
          const newSpeaker = await Speaker.create(speakerObj);
          processedSpeakers.push(newSpeaker);
          created++;
        }
      } catch (err) {
        console.error(`Error processing speaker ${speakerData.name || 'unknown'}:`, err);
        errors++;
      }
    }
    
    // Delete the uploaded file
    try {
      fs.unlinkSync(req.file.path);
      console.log(`Temporary Excel file deleted: ${req.file.path}`);
    } catch (err) {
      console.error('Error deleting temporary file:', err);
    }
    
    return res.status(200).json({
      message: `Successfully processed ${speakers.length} speakers`,
      created,
      updated,
      errors,
      speakers: processedSpeakers
    });
    
  } catch (error) {
    console.error('Error importing speakers from Excel:', error);
    return res.status(500).json({ 
      message: 'Error importing speakers from Excel', 
      error: error.message 
    });
  }
};

module.exports = {
  addSpeaker,
  getSpeakers,
  getSpeakerById,
  getSpeakerFlagImage,
  getSpeakerImage,
  updateSpeaker,
  deleteSpeaker,
  importSpeakersFromExcel
}; 