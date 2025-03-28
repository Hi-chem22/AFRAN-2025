const express = require('express');
const router = express.Router();
const Video = require('../models/videoModel');

// @desc    Get all videos
// @route   GET /api/videos
// @access  Public
router.get('/', async (req, res) => {
  try {
    const videos = await Video.find()
      .sort({ createdAt: -1 })
      .populate({
        path: 'sessionId',
        select: 'title startTime endTime date room dayId roomId chairpersons subsessionTexts description duration',
        populate: [
          { path: 'dayId' },
          { path: 'roomId' }
        ]
      });
    
    res.json(videos);
  } catch (error) {
    console.error('Error fetching videos:', error);
    res.status(500).json({ message: 'Error fetching videos', error: error.message });
  }
});

// @desc    Get videos by session ID
// @route   GET /api/videos/session/:sessionId
// @access  Public
router.get('/session/:sessionId', async (req, res) => {
  try {
    const videos = await Video.find({ 
      sessionId: req.params.sessionId,
      active: true 
    })
    .populate({
      path: 'sessionId',
      select: 'title startTime endTime date room dayId roomId chairpersons subsessionTexts description duration'
    })
    .sort({ order: 1, date: -1 });
    
    res.json(videos);
  } catch (error) {
    console.error('Error fetching session videos:', error);
    res.status(500).json({ message: 'Error fetching session videos' });
  }
});

// @desc    Get video by ID
// @route   GET /api/videos/:id
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const video = await Video.findById(req.params.id)
      .populate({
        path: 'sessionId',
        select: 'title startTime endTime date room dayId roomId chairpersons subsessionTexts description duration',
        populate: [
          { path: 'dayId' },
          { path: 'roomId' }
        ]
      });
    
    if (!video) {
      return res.status(404).json({ message: 'Video not found' });
    }
    
    res.json(video);
  } catch (error) {
    console.error('Error fetching video:', error);
    res.status(500).json({ message: 'Error fetching video', error: error.message });
  }
});

// @desc    Create new video with direct link
// @route   POST /api/videos
// @access  Public (consider adding authentication for production)
router.post('/', async (req, res) => {
  try {
    const { title, description, url, sessionId, category, speaker, featured, thumbnailUrl } = req.body;

    // Validate required fields
    if (!title || !url) {
      return res.status(400).json({ message: 'Title and video URL are required' });
    }

    // Create new video object
    const newVideo = new Video({
      title,
      description: description || '',
      url,
      sessionId: sessionId || null,
      category: category || 'other',
      speaker: speaker || '',
      featured: featured || false,
      thumbnailUrl: thumbnailUrl || '',
      active: true
    });

    const savedVideo = await newVideo.save();
    
    // Populate session data in the response
    const populatedVideo = await Video.findById(savedVideo._id)
      .populate({
        path: 'sessionId',
        select: 'title startTime endTime date room dayId roomId chairpersons subsessionTexts description duration'
      });
      
    res.status(201).json(populatedVideo);
  } catch (error) {
    console.error('Error creating video:', error);
    res.status(500).json({ message: 'Error creating video', error: error.message });
  }
});

// @desc    Update video
// @route   PUT /api/videos/:id
// @access  Public (consider adding authentication for production)
router.put('/:id', async (req, res) => {
  try {
    const updatedVideo = await Video.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate({
      path: 'sessionId',
      select: 'title startTime endTime date room dayId roomId chairpersons subsessionTexts description duration'
    });
    
    if (!updatedVideo) {
      return res.status(404).json({ message: 'Video not found' });
    }
    
    res.json(updatedVideo);
  } catch (error) {
    console.error('Error updating video:', error);
    res.status(500).json({ message: 'Error updating video', error: error.message });
  }
});

// @desc    Delete video
// @route   DELETE /api/videos/:id
// @access  Public (consider adding authentication for production)
router.delete('/:id', async (req, res) => {
  try {
    const deletedVideo = await Video.findByIdAndDelete(req.params.id);
    
    if (!deletedVideo) {
      return res.status(404).json({ message: 'Video not found' });
    }
    
    res.json({ message: 'Video deleted successfully' });
  } catch (error) {
    console.error('Error deleting video:', error);
    res.status(500).json({ message: 'Error deleting video', error: error.message });
  }
});

module.exports = router;
