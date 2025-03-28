const mongoose = require('mongoose');
const Speaker = require('./models/speaker');
require('dotenv').config();

async function findDuplicateSpeakers() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');

    const speakers = await Speaker.find().lean();
    console.log(`Total speakers: ${speakers.length}`);

    // Group speakers by name (case-insensitive)
    const speakersByName = {};
    speakers.forEach(speaker => {
      const name = speaker.name.toLowerCase().trim();
      if (!speakersByName[name]) {
        speakersByName[name] = [];
      }
      speakersByName[name].push(speaker);
    });

    // Find names with multiple speakers
    const duplicateNames = Object.entries(speakersByName)
      .filter(([name, speakerList]) => speakerList.length > 1);
    
    console.log(`Found ${duplicateNames.length} duplicate names:`);
    
    duplicateNames.forEach(([name, dupes]) => {
      console.log(`\nDuplicate name: "${name}"`);
      
      // Sort duplicates by creation date (oldest first)
      dupes.sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
      
      // Keep the oldest, mark others for deletion
      const toKeep = dupes[0];
      const toDelete = dupes.slice(1);
      
      console.log(`  Keep: ${toKeep._id} (created: ${toKeep.createdAt})`);
      console.log(`  Delete: ${toDelete.map(d => d._id).join(', ')}`);
    });

    console.log('\nSummary of IDs to delete:');
    const idsToDelete = duplicateNames.flatMap(([name, dupes]) => 
      dupes.slice(1).map(d => d._id)
    );
    console.log(idsToDelete.join(','));
    
    // Exit cleanly
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
    
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

findDuplicateSpeakers(); 