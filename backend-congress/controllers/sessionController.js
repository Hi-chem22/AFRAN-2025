const { Session, Room, Day, Subsession, Chairperson, Speaker } = require('../models');
const XLSX = require('xlsx');

// Ajouter une nouvelle session
const addSession = async (req, res) => {
  try {
    const { 
      title, 
      room, 
      roomId, 
      day, 
      dayId, 
      startTime, 
      endTime, 
      description, 
      speakers,
      chairpersons,
      chairpersonRefs,
      subsessionTexts,
      labLogoUrl 
    } = req.body;

    if (!title || !startTime || !endTime) {
      return res.status(400).json({ message: 'Title, start time, and end time are required' });
    }

    // Find or create day
    let finalDayId = dayId;
    if (!finalDayId && day) {
      let dayObj = await Day.findOne({ dayNumber: day });
      if (!dayObj) {
        dayObj = await Day.create({ dayNumber: day });
      }
      finalDayId = dayObj._id;
    }

    // Find or create room
    let finalRoomId = roomId;
    if (!finalRoomId && room) {
      let roomObj = await Room.findOne({ name: room });
      if (!roomObj) {
        roomObj = await Room.create({ name: room });
      }
      finalRoomId = roomObj._id;
    }

    // Calculate duration
    const duration = calculateDuration(startTime, endTime);

    // Handle chairperson references
    let finalChairpersonRefs = chairpersonRefs || [];
    if (!finalChairpersonRefs.length && chairpersons) {
      // If we have chairpersons as text but no refs, create refs from the text
      const chairNames = chairpersons.split(',').map(name => name.trim());
      for (const name of chairNames) {
        if (!name) continue;
        
        let chairperson = await Chairperson.findOne({ name });
        if (!chairperson) {
          chairperson = await Chairperson.create({ name });
        }
        finalChairpersonRefs.push(chairperson._id);
      }
    }

    // Create session with all the data
    const session = await Session.create({
      title,
      room,
      roomId: finalRoomId,
      day,
      dayId: finalDayId,
      startTime,
      endTime,
      duration,
      description,
      speakers: speakers || [],
      chairpersons: chairpersons || '',
      chairpersonRefs: finalChairpersonRefs,
      subsessionTexts: subsessionTexts || [],
      labLogoUrl: labLogoUrl || ''
    });

    res.status(201).json({
      message: 'Session created successfully',
      session
    });
  } catch (error) {
    console.error('❌ Error creating session:', error);
    res.status(500).json({ message: 'Error creating session', error: error.message });
  }
};

// Récupérer toutes les sessions
const getSessions = async (req, res) => {
  try {
    let sessions = await Session.find()
      .populate('roomId')
      .populate('dayId')
      .populate('speakers')
      .populate('chairpersonRefs')
      .populate({
        path: 'subsessions',
        populate: { 
          path: 'speakers'
        }
      });

    // Format the sessions response
    sessions = sessions.map(session => {
      const formattedSession = session.toObject();
      
      // Ensure all fields are present
      formattedSession.duration = calculateDuration(session.startTime, session.endTime);
      
      // Prioritize chairpersons text field if it exists
      if (!formattedSession.chairpersons && formattedSession.chairpersonRefs && formattedSession.chairpersonRefs.length > 0) {
        formattedSession.chairpersons = formattedSession.chairpersonRefs
          .map(chair => chair.name)
          .filter(Boolean)
          .join(', ');
      }

      // Handle subsessions (both text-based and reference-based)
      if (formattedSession.subsessionTexts && formattedSession.subsessionTexts.length) {
        // If we have text-based subsessions, use them directly
        formattedSession.subsessionTexts = formattedSession.subsessionTexts.map(subsession => {
          // Format subsubsessions if they exist
          const formattedSubsubsessions = subsession.subsubsessions && subsession.subsubsessions.length > 0 
            ? subsession.subsubsessions.map(subsubsession => {
                return {
                  ...subsubsession,
                  duration: calculateDuration(subsubsession.startTime, subsubsession.endTime)
                };
              })
            : [];
            
          return {
            ...subsession,
            duration: calculateDuration(subsession.startTime, subsession.endTime),
            subsubsessions: formattedSubsubsessions
          };
        });
      } else if (formattedSession.subsessions && formattedSession.subsessions.length) {
        // Otherwise, generate text-based subsessions from references
        formattedSession.subsessionTexts = formattedSession.subsessions.map(subsession => {
          // Format subsubsessions if they exist
          const formattedSubsubsessions = subsession.subsubsessions && subsession.subsubsessions.length > 0 
            ? subsession.subsubsessions.map(subsubsession => {
                return {
                  title: subsubsession.title,
                  startTime: subsubsession.startTime || '',
                  endTime: subsubsession.endTime || '',
                  duration: calculateDuration(subsubsession.startTime, subsubsession.endTime),
                  speakerIds: subsubsession.speakers ? subsubsession.speakers.map(s => s._id.toString()) : [],
                  description: subsubsession.description || ''
                };
              })
            : [];
            
          return {
            title: subsession.title,
            startTime: subsession.startTime || '',
            endTime: subsession.endTime || '',
            duration: calculateDuration(subsession.startTime, subsession.endTime),
            speakerIds: subsession.speakers ? subsession.speakers.map(s => s._id.toString()) : [],
            description: subsession.description || '',
            subsubsessions: formattedSubsubsessions
          };
        });
      }

      return formattedSession;
    });

    res.json(sessions);
  } catch (error) {
    console.error('❌ Error retrieving sessions:', error);
    res.status(500).json({ message: 'Error retrieving sessions', error: error.message });
  }
};

// Helper function to convert chairpersons array to text
const chairpersonsToText = (chairpersonRefs) => {
  if (!chairpersonRefs || chairpersonRefs.length === 0) return '';
  
  return chairpersonRefs
    .map(chairperson => chairperson.name)
    .join(', ');
};

// Helper function to calculate duration from startTime and endTime
const calculateDuration = (startTime, endTime) => {
  if (!startTime || !endTime) return '';
  
  try {
    // Parse times (assuming format: "HH:MM")
    const [startHour, startMinute] = startTime.split(':').map(Number);
    const [endHour, endMinute] = endTime.split(':').map(Number);
    
    // Convert to minutes
    const startTotalMinutes = startHour * 60 + startMinute;
    const endTotalMinutes = endHour * 60 + endMinute;
    
    // Calculate difference
    let diffMinutes = endTotalMinutes - startTotalMinutes;
    if (diffMinutes < 0) {
      diffMinutes += 24 * 60; // Add a day if end time is on the next day
    }
    
    // Convert back to hours and minutes
    const durationHours = Math.floor(diffMinutes / 60);
    const durationMinutes = diffMinutes % 60;
    
    // Format: "Xh Ym" or "Xh" or "Ym"
    if (durationHours > 0 && durationMinutes > 0) {
      return `${durationHours}h ${durationMinutes}m`;
    } else if (durationHours > 0) {
      return `${durationHours}h`;
    } else {
      return `${durationMinutes}m`;
    }
  } catch (e) {
    return '';
  }
};

// Helper function to format subsessions into the new structure
const formatSubsessions = (subsessions) => {
  if (!subsessions || subsessions.length === 0) return [];
  
  return subsessions.map(subsession => {
    const duration = calculateDuration(subsession.startTime, subsession.endTime);
    
    // Format subsubsessions if they exist
    const formattedSubsubsessions = subsession.subsubsessions && subsession.subsubsessions.length > 0 
      ? subsession.subsubsessions.map(subsubsession => {
          return {
            title: subsubsession.title,
            startTime: subsubsession.startTime,
            endTime: subsubsession.endTime,
            duration: calculateDuration(subsubsession.startTime, subsubsession.endTime),
            description: subsubsession.description,
            speakerIds: subsubsession.speakers ? subsubsession.speakers.map(speakerId => speakerId.toString()) : []
          };
        })
      : [];
    
    return {
      title: subsession.title,
      startTime: subsession.startTime,
      endTime: subsession.endTime,
      duration: duration,
      description: subsession.description,
      speakerIds: subsession.speakers ? subsession.speakers.map(speaker => speaker._id.toString()) : [],
      subsubsessions: formattedSubsubsessions
    };
  });
};

// Récupérer une session par ID
const getSessionById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const session = await Session.findById(id)
      .populate('roomId')
      .populate('dayId')
      .populate('speakers')
      .populate('chairpersonRefs')
      .populate({
        path: 'subsessions',
        populate: {
          path: 'speakers'
        }
      });
      
    if (!session) {
      return res.status(404).json({ message: 'Session not found' });
    }

    // Format the session response
    const formattedSession = session.toObject();
    
    // Ensure all fields are present
    formattedSession.duration = calculateDuration(session.startTime, session.endTime);
    
    // Prioritize chairpersons text field if it exists
    if (!formattedSession.chairpersons && formattedSession.chairpersonRefs && formattedSession.chairpersonRefs.length > 0) {
      formattedSession.chairpersons = formattedSession.chairpersonRefs
        .map(chair => chair.name)
        .filter(Boolean)
        .join(', ');
    }

    // Handle subsessions (both text-based and reference-based)
    if (formattedSession.subsessionTexts && formattedSession.subsessionTexts.length) {
      // If we have text-based subsessions, use them directly
      formattedSession.subsessionTexts = formattedSession.subsessionTexts.map(subsession => {
        // Format subsubsessions if they exist
        const formattedSubsubsessions = subsession.subsubsessions && subsession.subsubsessions.length > 0 
          ? subsession.subsubsessions.map(subsubsession => {
              return {
                ...subsubsession,
                duration: calculateDuration(subsubsession.startTime, subsubsession.endTime)
              };
            })
          : [];
          
        return {
          ...subsession,
          duration: calculateDuration(subsession.startTime, subsession.endTime),
          subsubsessions: formattedSubsubsessions
        };
      });
    } else if (formattedSession.subsessions && formattedSession.subsessions.length) {
      // Otherwise, generate text-based subsessions from references
      formattedSession.subsessionTexts = formattedSession.subsessions.map(subsession => {
        // Format subsubsessions if they exist
        const formattedSubsubsessions = subsession.subsubsessions && subsession.subsubsessions.length > 0 
          ? subsession.subsubsessions.map(subsubsession => {
              return {
                title: subsubsession.title,
                startTime: subsubsession.startTime || '',
                endTime: subsubsession.endTime || '',
                duration: calculateDuration(subsubsession.startTime, subsubsession.endTime),
                speakerIds: subsubsession.speakers ? subsubsession.speakers.map(s => s._id.toString()) : [],
                description: subsubsession.description || ''
              };
            })
          : [];
          
        return {
          title: subsession.title,
          startTime: subsession.startTime || '',
          endTime: subsession.endTime || '',
          duration: calculateDuration(subsession.startTime, subsession.endTime),
          speakerIds: subsession.speakers ? subsession.speakers.map(s => s._id.toString()) : [],
          description: subsession.description || '',
          subsubsessions: formattedSubsubsessions
        };
      });
    }

    res.json(formattedSession);
  } catch (error) {
    console.error('❌ Error retrieving session:', error);
    res.status(500).json({ message: 'Error retrieving session', error: error.message });
  }
};

// Récupérer les sessions par jour et par salle
const getSessionsByDayAndRoom = async (req, res) => {
  try {
    const { dayId, roomId, day, room } = req.query;
    
    // Build query based on provided parameters
    const query = {};
    if (dayId) query.dayId = dayId;
    if (roomId) query.roomId = roomId;
    if (day && !dayId) {
      const foundDay = await Day.findOne({ dayNumber: day });
      if (foundDay) query.dayId = foundDay._id;
    }
    if (room && !roomId) {
      const foundRoom = await Room.findOne({ name: room });
      if (foundRoom) query.roomId = foundRoom._id;
    }
    
    let sessions = await Session.find(query)
      .populate('roomId')
      .populate('dayId')
      .populate('speakers')
      .populate('chairpersonRefs')
      .populate({
        path: 'subsessions',
        populate: { 
          path: 'speakers'
        }
      });
      
    // Format the sessions response
    sessions = sessions.map(session => {
      const formattedSession = session.toObject();
      
      // Ensure all fields are present
      formattedSession.duration = calculateDuration(session.startTime, session.endTime);
      
      // Prioritize chairpersons text field if it exists
      if (!formattedSession.chairpersons && formattedSession.chairpersonRefs && formattedSession.chairpersonRefs.length > 0) {
        formattedSession.chairpersons = formattedSession.chairpersonRefs
          .map(chair => chair.name)
          .filter(Boolean)
          .join(', ');
      }

      // Handle subsessions (both text-based and reference-based)
      if (formattedSession.subsessionTexts && formattedSession.subsessionTexts.length) {
        // If we have text-based subsessions, use them directly
        formattedSession.subsessionTexts = formattedSession.subsessionTexts.map(subsession => {
          // Format subsubsessions if they exist
          const formattedSubsubsessions = subsession.subsubsessions && subsession.subsubsessions.length > 0 
            ? subsession.subsubsessions.map(subsubsession => {
                return {
                  ...subsubsession,
                  duration: calculateDuration(subsubsession.startTime, subsubsession.endTime)
                };
              })
            : [];
            
          return {
            ...subsession,
            duration: calculateDuration(subsession.startTime, subsession.endTime),
            subsubsessions: formattedSubsubsessions
          };
        });
      } else if (formattedSession.subsessions && formattedSession.subsessions.length) {
        // Otherwise, generate text-based subsessions from references
        formattedSession.subsessionTexts = formattedSession.subsessions.map(subsession => {
          // Format subsubsessions if they exist
          const formattedSubsubsessions = subsession.subsubsessions && subsession.subsubsessions.length > 0 
            ? subsession.subsubsessions.map(subsubsession => {
                return {
                  title: subsubsession.title,
                  startTime: subsubsession.startTime || '',
                  endTime: subsubsession.endTime || '',
                  duration: calculateDuration(subsubsession.startTime, subsubsession.endTime),
                  speakerIds: subsubsession.speakers ? subsubsession.speakers.map(s => s._id.toString()) : [],
                  description: subsubsession.description || ''
                };
              })
            : [];
            
          return {
            title: subsession.title,
            startTime: subsession.startTime || '',
            endTime: subsession.endTime || '',
            duration: calculateDuration(subsession.startTime, subsession.endTime),
            speakerIds: subsession.speakers ? subsession.speakers.map(s => s._id.toString()) : [],
            description: subsession.description || '',
            subsubsessions: formattedSubsubsessions
          };
        });
      }

      return formattedSession;
    });

    res.json(sessions);
  } catch (error) {
    console.error('❌ Error retrieving sessions by day and room:', error);
    res.status(500).json({ message: 'Error retrieving sessions', error: error.message });
  }
};

// Mettre à jour une session
const updateSession = async (req, res) => {
  try {
    const { id } = req.params;
    const { 
      title, 
      room, 
      roomId, 
      day, 
      dayId, 
      startTime, 
      endTime, 
      description, 
      speakers,
      chairpersons,
      chairpersonRefs,
      subsessionTexts 
    } = req.body;

    // Find the session
    const session = await Session.findById(id);
    if (!session) {
      return res.status(404).json({ message: 'Session not found' });
    }

    // Find or create day
    let finalDayId = dayId;
    if (!finalDayId && day) {
      let dayObj = await Day.findOne({ dayNumber: day });
      if (!dayObj) {
        dayObj = await Day.create({ dayNumber: day });
      }
      finalDayId = dayObj._id;
    }

    // Find or create room
    let finalRoomId = roomId;
    if (!finalRoomId && room) {
      let roomObj = await Room.findOne({ name: room });
      if (!roomObj) {
        roomObj = await Room.create({ name: room });
      }
      finalRoomId = roomObj._id;
    }

    // Calculate duration if start/end times provided
    let duration = session.duration;
    if (startTime && endTime) {
      duration = calculateDuration(startTime, endTime);
    }

    // Handle chairperson references
    let finalChairpersonRefs = chairpersonRefs || session.chairpersonRefs;
    if (chairpersons !== undefined && (!finalChairpersonRefs || finalChairpersonRefs.length === 0)) {
      // If we have chairpersons as text but no refs, create refs from the text
      const chairNames = chairpersons.split(',').map(name => name.trim());
      finalChairpersonRefs = [];
      for (const name of chairNames) {
        if (!name) continue;
        
        let chairperson = await Chairperson.findOne({ name });
        if (!chairperson) {
          chairperson = await Chairperson.create({ name });
        }
        finalChairpersonRefs.push(chairperson._id);
      }
    }

    // Update session with all the data
    const updates = {
      ...(title && { title }),
      ...(room && { room }),
      ...(finalRoomId && { roomId: finalRoomId }),
      ...(day && { day }),
      ...(finalDayId && { dayId: finalDayId }),
      ...(startTime && { startTime }),
      ...(endTime && { endTime }),
      ...(duration && { duration }),
      ...(description !== undefined && { description }),
      ...(speakers && { speakers }),
      ...(chairpersons !== undefined && { chairpersons }),
      ...(finalChairpersonRefs && finalChairpersonRefs.length > 0 && { chairpersonRefs: finalChairpersonRefs }),
      ...(subsessionTexts && { subsessionTexts })
    };

      const updatedSession = await Session.findByIdAndUpdate(
      id, 
      updates, 
      { new: true }
      )
        .populate('roomId')
        .populate('dayId')
        .populate('speakers')
    .populate('chairpersonRefs')
        .populate({
          path: 'subsessions',
          populate: { 
            path: 'speakers'
          }
        });
      
    // Format the session response
    const formattedSession = updatedSession.toObject();
    
    // Ensure all fields are present
    formattedSession.duration = calculateDuration(updatedSession.startTime, updatedSession.endTime);
    
    // Prioritize chairpersons text field if it exists
    if (!formattedSession.chairpersons && formattedSession.chairpersonRefs && formattedSession.chairpersonRefs.length > 0) {
      formattedSession.chairpersons = formattedSession.chairpersonRefs
        .map(chair => chair.name)
        .filter(Boolean)
        .join(', ');
    }

    // Handle subsessions (both text-based and reference-based)
    if (formattedSession.subsessionTexts && formattedSession.subsessionTexts.length) {
      // If we have text-based subsessions, use them directly
      formattedSession.subsessionTexts = formattedSession.subsessionTexts.map(subsession => {
        // Format subsubsessions if they exist
        const formattedSubsubsessions = subsession.subsubsessions && subsession.subsubsessions.length > 0 
          ? subsession.subsubsessions.map(subsubsession => {
              return {
                ...subsubsession,
                duration: calculateDuration(subsubsession.startTime, subsubsession.endTime)
              };
            })
          : [];
          
        return {
          ...subsession,
          duration: calculateDuration(subsession.startTime, subsession.endTime),
          subsubsessions: formattedSubsubsessions
        };
      });
    } else if (formattedSession.subsessions && formattedSession.subsessions.length) {
      // Otherwise, generate text-based subsessions from references
      formattedSession.subsessionTexts = formattedSession.subsessions.map(subsession => {
        // Format subsubsessions if they exist
        const formattedSubsubsessions = subsession.subsubsessions && subsession.subsubsessions.length > 0 
          ? subsession.subsubsessions.map(subsubsession => {
              return {
                title: subsubsession.title,
                startTime: subsubsession.startTime || '',
                endTime: subsubsession.endTime || '',
                duration: calculateDuration(subsubsession.startTime, subsubsession.endTime),
                speakerIds: subsubsession.speakers ? subsubsession.speakers.map(s => s._id.toString()) : [],
                description: subsubsession.description || ''
              };
            })
          : [];
          
        return {
          title: subsession.title,
          startTime: subsession.startTime || '',
          endTime: subsession.endTime || '',
          duration: calculateDuration(subsession.startTime, subsession.endTime),
          speakerIds: subsession.speakers ? subsession.speakers.map(s => s._id.toString()) : [],
          description: subsession.description || '',
          subsubsessions: formattedSubsubsessions
        };
      });
    }

    res.json({
      message: 'Session updated successfully',
      session: formattedSession
    });
  } catch (error) {
    console.error('❌ Error updating session:', error);
    res.status(500).json({ message: 'Error updating session', error: error.message });
  }
};

// Supprimer une session
const deleteSession = async (req, res) => {
  try {
    const session = await Session.findById(req.params.id);
    
    if (!session) {
      return res.status(404).json({ error: 'Session not found' });
    }
    
    // Supprimer les sous-sessions associées
    if (session.subsessions && session.subsessions.length > 0) {
      await Subsession.deleteMany({ _id: { $in: session.subsessions } });
    }
    
    await Session.findByIdAndDelete(req.params.id);
    
    res.status(200).json({ message: 'Session deleted successfully' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Ajouter ou supprimer des modérateurs
const updateSessionChairpersons = async (req, res) => {
  try {
    const { id } = req.params;
    const { chairpersonIds } = req.body;

    // Vérifier si la session existe
    const session = await Session.findById(id);
    if (!session) {
      return res.status(404).json({ error: 'Session non trouvée' });
    }

    // Vérifier si les modérateurs existent
    if (chairpersonIds && chairpersonIds.length > 0) {
      const chairpersonsCount = await Chairperson.countDocuments({
        _id: { $in: chairpersonIds }
      });
      
      if (chairpersonsCount !== chairpersonIds.length) {
        return res.status(400).json({ error: 'Un ou plusieurs modérateurs n\'existent pas' });
      }
    }

    // Mettre à jour les modérateurs de la session
    session.chairpersonRefs = chairpersonIds || [];
    await session.save();

    // Retourner la session mise à jour
    const updatedSession = await Session.findById(id)
      .populate('roomId')
      .populate('dayId')
      .populate('speakers')
      .populate('chairpersonRefs')
      .populate({
        path: 'subsessions',
        populate: { 
          path: 'speakers'
        }
      });

    res.status(200).json(updatedSession);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

const importSessionsFromExcel = async (req, res) => {
  try {
    console.log('Import sessions from Excel request received');
    console.log('Request body:', req.body);
    console.log('Request files:', req.files ? Object.keys(req.files) : 'No req.files');
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
    
    // Check if Sessions sheet exists
    if (!workbook.SheetNames.includes('Sessions')) {
      return res.status(400).json({ message: 'Excel file must contain a "Sessions" sheet' });
    }
    
    const sessionsSheet = workbook.Sheets['Sessions'];
    const sessions = XLSX.utils.sheet_to_json(sessionsSheet);
    
    if (sessions.length === 0) {
      return res.status(400).json({ message: 'No sessions found in Excel file' });
    }
    
    console.log(`Found ${sessions.length} sessions`);
    console.log(`Sample session data: ${JSON.stringify(sessions[0])}`);
    
    // Process sessions
    const processedSessions = [];
    const sessionMap = {};
    
    for (const sessionData of sessions) {
      console.log(`Processing session: ${JSON.stringify(sessionData)}`);
      
      // Handle Room - can be a name or MongoDB ID
      let roomId;
      if (sessionData['Room ID']) {
        // Use direct MongoDB ID if provided
        try {
          const room = await Room.findById(sessionData['Room ID']);
          if (room) {
            roomId = room._id;
          } else {
            console.log(`Room with ID ${sessionData['Room ID']} not found`);
          }
        } catch (err) {
          console.log(`Invalid room ID: ${sessionData['Room ID']}`);
        }
      } else if (sessionData.Room) {
        // Look up by name
        const room = await Room.findOne({ name: sessionData.Room });
        if (room) {
          roomId = room._id;
        } else {
          const newRoom = await Room.create({ name: sessionData.Room });
          roomId = newRoom._id;
        }
      }
      
      // Handle Day - can be a number or MongoDB ID
      let dayId;
      if (sessionData['Day ID']) {
        // Use direct MongoDB ID if provided
        try {
          const day = await Day.findById(sessionData['Day ID']);
          if (day) {
            dayId = day._id;
          } else {
            console.log(`Day with ID ${sessionData['Day ID']} not found`);
          }
        } catch (err) {
          console.log(`Invalid day ID: ${sessionData['Day ID']}`);
        }
      } else if (sessionData.Day) {
        // Only attempt to convert to number if it's actually a number
        let dayNumber;
        if (typeof sessionData.Day === 'number') {
          dayNumber = sessionData.Day;
        } else if (!isNaN(Number(sessionData.Day))) {
          dayNumber = Number(sessionData.Day);
        }
        
        if (dayNumber !== undefined) {
          const day = await Day.findOne({ number: dayNumber });
          if (day) {
            dayId = day._id;
          } else {
            const newDay = await Day.create({ 
              number: dayNumber,
              date: new Date() // Default date
            });
            dayId = newDay._id;
          }
        } else {
          console.log(`Could not process Day value: ${sessionData.Day}`);
        }
      }
      
      // Handle speakers if provided
      let speakers = [];
      if (sessionData['Speaker IDs']) {
        const speakerIds = sessionData['Speaker IDs'].split(',').map(id => id.trim());
        // Only add valid speaker IDs
        for (const speakerId of speakerIds) {
          try {
            // Check if speaker exists
            const speaker = await Speaker.findById(speakerId);
            if (speaker) {
              speakers.push(speakerId);
              console.log(`Added speaker ${speakerId} to session speakers list`);
            } else {
              console.log(`Speaker with ID ${speakerId} not found`);
            }
          } catch (err) {
            console.log(`Invalid speaker ID: ${speakerId}: ${err.message}`);
          }
        }
      }
      
      // Create the session
      const session = {
        title: sessionData['Session Title'],
        description: sessionData['Description'] || '',
        chairpersons: sessionData['Chairs'] || '',
        speakers: speakers,
        subsessionTexts: [] // Initialize empty subsession texts array
      };
      
      console.log(`Session speakers list: ${JSON.stringify(session.speakers)}`);
      
      // Only add fields if they exist
      if (roomId) session.roomId = roomId;
      if (dayId) session.dayId = dayId;
      if (sessionData['Start Time']) session.startTime = sessionData['Start Time'];
      if (sessionData['End Time']) session.endTime = sessionData['End Time'];
      
      // Create session in database
      const createdSession = await Session.create(session);
      processedSessions.push(createdSession);
      
      // Store the mapping between Excel ID and MongoDB ID
      if (sessionData.ID !== undefined) {
        sessionMap[sessionData.ID] = createdSession._id;
        console.log(`Mapped Excel session ID ${sessionData.ID} to MongoDB ID ${createdSession._id}`);
      }
    }
    
    // Process subsessions if they exist
    if (workbook.SheetNames.includes('Subsessions')) {
      console.log('Processing subsessions...');
      const subsessionsSheet = workbook.Sheets['Subsessions'];
      const subsessions = XLSX.utils.sheet_to_json(subsessionsSheet);
      console.log(`Found ${subsessions.length} subsessions`);
      
      // Group subsessions by Session ID
      const subsessionsBySession = {};
      for (const subsessionData of subsessions) {
        const sessionId = subsessionData['Session ID'];
        if (!subsessionsBySession[sessionId]) {
          subsessionsBySession[sessionId] = [];
        }
        subsessionsBySession[sessionId].push(subsessionData);
      }
      
      // Process each group of subsessions
      for (const [excelSessionId, subsessionGroup] of Object.entries(subsessionsBySession)) {
        const mongoDbSessionId = sessionMap[excelSessionId];
        if (!mongoDbSessionId) {
          console.log(`Cannot find MongoDB session ID for Excel session ID ${excelSessionId}`);
          continue;
        }
        
        console.log(`Processing ${subsessionGroup.length} subsessions for session ${mongoDbSessionId}`);
        
        // Get the session
        const session = await Session.findById(mongoDbSessionId);
        if (!session) {
          console.log(`Session with ID ${mongoDbSessionId} not found`);
          continue;
        }
        
        // Process subsessions
        const subsessionTexts = [];
        
        for (const subsessionData of subsessionGroup) {
          console.log(`Processing subsession: ${JSON.stringify(subsessionData)}`);
          
          // Handle subsession speakers
          const subsessionSpeakers = [];
          const speakerIdsForText = [];
          
          if (subsessionData['Speaker IDs']) {
            // Multiple speakers support - split by comma
            const speakerIds = subsessionData['Speaker IDs'].split(',').map(id => id.trim());
            
            for (const speakerId of speakerIds) {
              try {
                // Check if speaker exists
                const speaker = await Speaker.findById(speakerId);
                if (speaker) {
                  subsessionSpeakers.push(speakerId);
                  speakerIdsForText.push(speakerId);
                  console.log(`Added speaker ${speakerId} to subsession speakers list`);
                } else {
                  console.log(`Speaker with ID ${speakerId} not found`);
                }
              } catch (err) {
                console.log(`Invalid speaker ID: ${speakerId}: ${err.message}`);
              }
            }
          }
          
          // Create the subsession
          const subsession = await Subsession.create({
            sessionId: mongoDbSessionId,
            title: subsessionData['Title'],
            startTime: subsessionData['Start Time'],
            endTime: subsessionData['End Time'],
            speakerName: subsessionData['Speaker'] || '',
            speakerCountry: subsessionData['Speaker Country'] || '',
            speakerBio: subsessionData['Speaker Bio'] || '',
            speakerFlag: subsessionData['Speaker Flag'] || '',
            description: subsessionData['Description'] || '',
            speakers: subsessionSpeakers,
            subsubsessions: [] // Initialize empty subsubsessions array
          });
          
          // Prepare subsession text object for the session with subsubsessions array
          const subsessionText = {
            title: subsessionData['Title'],
            startTime: subsessionData['Start Time'] || '',
            endTime: subsessionData['End Time'] || '',
            duration: calculateDuration(subsessionData['Start Time'], subsessionData['End Time']),
            speakerIds: speakerIdsForText, // Use the string array for subsessionTexts
            description: subsessionData['Description'] || '',
            subsubsessions: [] // Initialize empty subsubsessions array
          };
          
          // Add the subsessionText to the array
          subsessionTexts.push(subsessionText);
        }
        
        // Update session with subsession texts
        session.subsessionTexts = subsessionTexts;
        await session.save();
        console.log(`Updated session ${mongoDbSessionId} with ${subsessionTexts.length} subsessions`);
      }
    }
    
    // Process subsubsessions if they exist
    if (workbook.SheetNames.includes('Subsubsessions')) {
      console.log('Processing subsubsessions...');
      const subsubsessionsSheet = workbook.Sheets['Subsubsessions'];
      const subsubsessions = XLSX.utils.sheet_to_json(subsubsessionsSheet);
      console.log(`Found ${subsubsessions.length} subsubsessions`);
      
      // Group subsubsessions by Session ID and Subsession Title
      const subsubsessionsBySubsession = {};
      for (const subsubsessionData of subsubsessions) {
        const sessionId = subsubsessionData['Session ID'];
        const subsessionTitle = subsubsessionData['Subsession Title'];
        const key = `${sessionId}:${subsessionTitle}`;
        
        if (!subsubsessionsBySubsession[key]) {
          subsubsessionsBySubsession[key] = [];
        }
        subsubsessionsBySubsession[key].push(subsubsessionData);
      }
      
      // Process each group of subsubsessions
      for (const [key, subsubsessionGroup] of Object.entries(subsubsessionsBySubsession)) {
        const [excelSessionId, subsessionTitle] = key.split(':');
        const mongoDbSessionId = sessionMap[excelSessionId];
        
        if (!mongoDbSessionId) {
          console.log(`Cannot find MongoDB session ID for Excel session ID ${excelSessionId}`);
          continue;
        }
        
        console.log(`Processing ${subsubsessionGroup.length} subsubsessions for session ${mongoDbSessionId}, subsession "${subsessionTitle}"`);
        
        // Get the session
        const session = await Session.findById(mongoDbSessionId);
        if (!session) {
          console.log(`Session with ID ${mongoDbSessionId} not found`);
          continue;
        }
        
        // Find the corresponding subsession 
        let subsession = await Subsession.findOne({
          sessionId: mongoDbSessionId,
          title: { $regex: new RegExp(`^${subsessionTitle.trim()}$`, 'i') }
        });
        
        if (!subsession) {
          // Try with all subsessions for this session and compare normalized titles
          const allSubsessions = await Subsession.find({
            sessionId: mongoDbSessionId
          });
          
          // Find subsession with closest normalized title match
          const normalizedSearchTitle = normalizeTitle(subsessionTitle);
          for (const candidate of allSubsessions) {
            const normalizedCandidateTitle = normalizeTitle(candidate.title);
            if (normalizedCandidateTitle === normalizedSearchTitle) {
              console.log(`Found subsession by normalized title: "${candidate.title}" matches "${subsessionTitle}"`);
              subsession = candidate;
              break;
            }
          }
          
          if (!subsession) {
            console.log(`Subsession "${subsessionTitle}" not found for session ${mongoDbSessionId} (normalized: "${normalizeTitle(subsessionTitle)}")`);
            continue;
          }
        }
        
        // Find the matching subsessionText entry in the session
        const subsessionIndex = session.subsessionTexts.findIndex(st => 
          normalizeTitle(st.title) === normalizeTitle(subsessionTitle)
        );
        
        if (subsessionIndex === -1) {
          console.log(`Subsession text "${subsessionTitle}" not found in session ${mongoDbSessionId}`);
          continue;
        }
        
        // Process subsubsessions
        for (const subsubsessionData of subsubsessionGroup) {
          console.log(`Processing subsubsession: ${JSON.stringify(subsubsessionData)}`);
          
          // Handle subsubsession speakers
          const subsubsessionSpeakers = [];
          const speakerIdsForText = [];
          
          if (subsubsessionData['Speaker IDs']) {
            // Multiple speakers support - split by comma
            const speakerIds = subsubsessionData['Speaker IDs'].split(',').map(id => id.trim());
            
            for (const speakerId of speakerIds) {
              try {
                // Check if speaker exists
                const speaker = await Speaker.findById(speakerId);
                if (speaker) {
                  subsubsessionSpeakers.push(speakerId);
                  speakerIdsForText.push(speakerId);
                  console.log(`Added speaker ${speakerId} to subsubsession speakers list`);
                } else {
                  console.log(`Speaker with ID ${speakerId} not found`);
                }
              } catch (err) {
                console.log(`Invalid speaker ID: ${speakerId}: ${err.message}`);
              }
            }
          }
          
          // Create the subsubsession object
          const subsubsession = {
            title: subsubsessionData['Title'],
            startTime: subsubsessionData['Start Time'],
            endTime: subsubsessionData['End Time'],
            description: subsubsessionData['Description'] || '',
            speakers: subsubsessionSpeakers
          };
          
          // Add the subsubsession to the subsession
          subsession.subsubsessions.push(subsubsession);
          
          // Add to subsessionTexts in the session document
          const subsubsessionText = {
            title: subsubsessionData['Title'],
            startTime: subsubsessionData['Start Time'] || '',
            endTime: subsubsessionData['End Time'] || '',
            duration: calculateDuration(subsubsessionData['Start Time'], subsubsessionData['End Time']),
            speakerIds: speakerIdsForText,
            description: subsubsessionData['Description'] || ''
          };
          
          // Ensure subsubsessions array exists
          if (!session.subsessionTexts[subsessionIndex].subsubsessions) {
            session.subsessionTexts[subsessionIndex].subsubsessions = [];
          }
          
          // Add the subsubsession text
          session.subsessionTexts[subsessionIndex].subsubsessions.push(subsubsessionText);
        }
        
        // Save the subsession with subsubsessions
        await subsession.save();
        console.log(`Updated subsession "${subsessionTitle}" with ${subsession.subsubsessions.length} subsubsessions`);
        
        // Save the session with updated subsessionTexts
        await session.save();
        console.log(`Updated session ${mongoDbSessionId} with subsubsessions data`);
      }
    }
    
    return res.status(201).json({ 
      message: 'Sessions imported successfully', 
      count: processedSessions.length
    });
    
  } catch (error) {
    console.error('Error importing sessions from Excel:', error);
    return res.status(500).json({ message: 'Error importing sessions from Excel', error: error.message });
  }
};

// Helper function to normalize session titles for comparison
const normalizeTitle = (title) => {
  if (!title) return '';
  // Remove extra whitespace, convert to lowercase, and remove common punctuation
  return title.trim().toLowerCase().replace(/[:.,-]+/g, '').replace(/\s+/g, ' ');
};

module.exports = {
  addSession,
  getSessions,
  getSessionById,
  getSessionsByDayAndRoom,
  updateSession,
  deleteSession,
  updateSessionChairpersons,
  importSessionsFromExcel 
}; 