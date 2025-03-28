const mongoose = require('mongoose');
const Speaker = require('./models/speaker');
const Session = require('./models/session');
const Subsession = require('./models/subsession');
require('dotenv').config();

// IDs of speakers to delete (duplicates)
const speakerIdsToDelete = [
  '67e01030eb931f01c3a924ba','67e037bd1edb37548cd081f4','67e037bd1edb37548cd081ca','67e037bd1edb37548cd081cb',
  '67e037bd1edb37548cd081cc','67e037bd1edb37548cd081cd','67e037bd1edb37548cd081ce','67e037bd1edb37548cd081cf',
  '67e037bd1edb37548cd081d0','67e037bd1edb37548cd081d1','67e037bd1edb37548cd081d2','67e037bd1edb37548cd081d3',
  '67e037bd1edb37548cd081d4','67e037bd1edb37548cd081d5','67e037bd1edb37548cd081d6','67e037bd1edb37548cd081d7',
  '67e037bd1edb37548cd081d8','67e037bd1edb37548cd081d9','67e037bd1edb37548cd081da','67e037bd1edb37548cd081db',
  '67e037bd1edb37548cd081dc','67e037bd1edb37548cd081dd','67e037bd1edb37548cd081de','67e037bd1edb37548cd081df',
  '67e037bd1edb37548cd081e0','67e037bd1edb37548cd081e1','67e037bd1edb37548cd081e2','67e037bd1edb37548cd081e3',
  '67e037bd1edb37548cd081e4','67e037bd1edb37548cd081e5','67e037bd1edb37548cd081e6','67e037bd1edb37548cd081e7',
  '67e037bd1edb37548cd081e8','67e037bd1edb37548cd081e9','67e037bd1edb37548cd081ea','67e037bd1edb37548cd081eb',
  '67e037bd1edb37548cd081ec','67e037bd1edb37548cd081ed','67e037bd1edb37548cd081ee','67e037bd1edb37548cd081ef',
  '67e037bd1edb37548cd081f0','67e037bd1edb37548cd081f1','67e037bd1edb37548cd081f2','67e037bd1edb37548cd081f3',
  '67e037bd1edb37548cd081f5','67e037bd1edb37548cd081f6','67e037bd1edb37548cd081f7','67e037bd1edb37548cd081f8',
  '67e037bd1edb37548cd081f9','67e037bd1edb37548cd081fa','67e037bd1edb37548cd081fb','67e037bd1edb37548cd081fc',
  '67e037bd1edb37548cd081fd','67e037bd1edb37548cd081fe','67e037bd1edb37548cd081ff','67e037bd1edb37548cd08200'
];

// Mapping of duplicate IDs to keep IDs
const speakerMapping = {
  '67e01030eb931f01c3a924ba': '67db3c536f2c0b5e95ca920c', // Ahmed SAEED
  '67e037bd1edb37548cd081f4': '67db3c536f2c0b5e95ca920c', // Ahmed SAEED
  '67e037bd1edb37548cd081ca': '67e01030eb931f01c3a92490', // Bianca Davidson
  '67e037bd1edb37548cd081cb': '67e01030eb931f01c3a92491', // Leigh Morton
  '67e037bd1edb37548cd081cc': '67e01030eb931f01c3a92492', // Razeen Davids
  '67e037bd1edb37548cd081cd': '67e01030eb931f01c3a92493', // Saraladevi Naicker
  '67e037bd1edb37548cd081ce': '67e01030eb931f01c3a92494', // Roser Torra
  '67e037bd1edb37548cd081cf': '67e01030eb931f01c3a92495', // Thomas Mueller
  '67e037bd1edb37548cd081d0': '67e01030eb931f01c3a92496', // Valerie Luyckx
  '67e037bd1edb37548cd081d1': '67e01030eb931f01c3a92497', // Sudakshina Ghosh
  '67e037bd1edb37548cd081d2': '67e01030eb931f01c3a92498', // Abir Bousetta
  '67e037bd1edb37548cd081d3': '67e01030eb931f01c3a92499', // Ahlem Achour
  '67e037bd1edb37548cd081d4': '67e01030eb931f01c3a9249a', // Ahmed Letaief
  '67e037bd1edb37548cd081d5': '67e01030eb931f01c3a9249b', // Amel Harzallah
  '67e037bd1edb37548cd081d6': '67e01030eb931f01c3a9249c', // Badreddine Ben Kaab
  '67e037bd1edb37548cd081d7': '67e01030eb931f01c3a9249d', // Emna Gaies
  '67e037bd1edb37548cd081d8': '67e01030eb931f01c3a9249e', // Faiçal Jerraya
  '67e037bd1edb37548cd081d9': '67e01030eb931f01c3a9249f', // Fatma Mnif Bousarsar
  '67e037bd1edb37548cd081da': '67e01030eb931f01c3a924a0', // Habib Skhiri
  '67e037bd1edb37548cd081db': '67e01030eb931f01c3a924a1', // Hafedh Fessi
  '67e037bd1edb37548cd081dc': '67e01030eb931f01c3a924a2', // Hafedh Hedri
  '67e037bd1edb37548cd081dd': '67e01030eb931f01c3a924a3', // Hanene Gaied
  '67e037bd1edb37548cd081de': '67e01030eb931f01c3a924a4', // Ikram Mami
  '67e037bd1edb37548cd081df': '67e01030eb931f01c3a924a5', // Imed Helal
  '67e037bd1edb37548cd081e0': '67e01030eb931f01c3a924a6', // Jannet Laabidi
  '67e037bd1edb37548cd081e1': '67e01030eb931f01c3a924a7', // Lamia Raies
  '67e037bd1edb37548cd081e2': '67e01030eb931f01c3a924a8', // Meriam Hajji
  '67e037bd1edb37548cd081e3': '67e01030eb931f01c3a924a9', // Mohamed Ben Hmida
  '67e037bd1edb37548cd081e4': '67e01030eb931f01c3a924aa', // Mohamed Jameleddine Manaa
  '67e037bd1edb37548cd081e5': '67e01030eb931f01c3a924ab', // Mohamed Mongi Bacha
  '67e037bd1edb37548cd081e6': '67e01030eb931f01c3a924ac', // Mouna Hammouda
  '67e037bd1edb37548cd081e7': '67e01030eb931f01c3a924ad', // Mouna Jerbi
  '67e037bd1edb37548cd081e8': '67e01030eb931f01c3a924ae', // Narjess Ben Aicha
  '67e037bd1edb37548cd081e9': '67e01030eb931f01c3a924af', // Rim Goucha
  '67e037bd1edb37548cd081ea': '67e01030eb931f01c3a924b0', // Samarra Badrouchi
  '67e037bd1edb37548cd081eb': '67e01030eb931f01c3a924b1', // Sameh Mabrouk
  '67e037bd1edb37548cd081ec': '67e01030eb931f01c3a924b2', // Sana Ouali
  '67e037bd1edb37548cd081ed': '67e01030eb931f01c3a924b3', // Soumaya Chargui
  '67e037bd1edb37548cd081ee': '67e01030eb931f01c3a924b4', // Taieb Ben Abdallah
  '67e037bd1edb37548cd081ef': '67e01030eb931f01c3a924b5', // Wissal Sahtout
  '67e037bd1edb37548cd081f0': '67e01030eb931f01c3a924b6', // Mourad Boufi
  '67e037bd1edb37548cd081f1': '67e01030eb931f01c3a924b7', // Mehmet Haberal
  '67e037bd1edb37548cd081f2': '67e01030eb931f01c3a924b8', // Rumeyza Kazancioglu
  '67e037bd1edb37548cd081f3': '67e01030eb931f01c3a924b9', // Robert Kalyesubula
  '67e037bd1edb37548cd081f5': '67e01030eb931f01c3a924bb', // Edwina Brown
  '67e037bd1edb37548cd081f6': '67e01030eb931f01c3a924bc', // Maria Pippias
  '67e037bd1edb37548cd081f7': '67e01030eb931f01c3a924bd', // Akinlolu Ojo
  '67e037bd1edb37548cd081f8': '67e01030eb931f01c3a924be', // Andrew Rule
  '67e037bd1edb37548cd081f9': '67e01030eb931f01c3a924bf', // Charu Malik
  '67e037bd1edb37548cd081fa': '67e01030eb931f01c3a924c0', // Christopher Atwater
  '67e037bd1edb37548cd081fb': '67e01030eb931f01c3a924c1', // Fernando C Fervenza
  '67e037bd1edb37548cd081fc': '67e01030eb931f01c3a924c2', // Hatem Amer
  '67e037bd1edb37548cd081fd': '67e01030eb931f01c3a924c3', // Iasmina Craici
  '67e037bd1edb37548cd081fe': '67e01030eb931f01c3a924c4', // Naim Issa
  '67e037bd1edb37548cd081ff': '67e01030eb931f01c3a924c5', // Rasheed Gbadegesin
  '67e037bd1edb37548cd08200': '67e01030eb931f01c3a924c6'  // Vesna Garovic
};

async function removeDuplicateSpeakers() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');
    
    // 1. Update any references in sessions and subsessions
    console.log('\nUpdating references in sessions...');
    
    // Update session.speakers array (replace duplicate IDs with original IDs)
    const sessionResults = await Session.find({ speakers: { $in: speakerIdsToDelete } });
    console.log(`Found ${sessionResults.length} sessions with references to duplicate speakers`);
    
    for (const session of sessionResults) {
      // Replace any duplicate speaker IDs with their "keep" versions
      const updatedSpeakers = session.speakers.map(speakerId => {
        const speakerIdStr = speakerId.toString();
        return speakerMapping[speakerIdStr] ? mongoose.Types.ObjectId(speakerMapping[speakerIdStr]) : speakerId;
      });
      
      // Update session
      await Session.updateOne(
        { _id: session._id },
        { $set: { speakers: updatedSpeakers } }
      );
      
      console.log(`Updated session: ${session._id}`);
    }
    
    // Update subsession.speakers array
    console.log('\nUpdating references in subsessions...');
    const subsessionResults = await Subsession.find({ speakers: { $in: speakerIdsToDelete } });
    console.log(`Found ${subsessionResults.length} subsessions with references to duplicate speakers`);
    
    for (const subsession of subsessionResults) {
      // Replace any duplicate speaker IDs with their "keep" versions
      const updatedSpeakers = subsession.speakers.map(speakerId => {
        const speakerIdStr = speakerId.toString();
        return speakerMapping[speakerIdStr] ? mongoose.Types.ObjectId(speakerMapping[speakerIdStr]) : speakerId;
      });
      
      // Update subsession
      await Subsession.updateOne(
        { _id: subsession._id },
        { $set: { speakers: updatedSpeakers } }
      );
      
      console.log(`Updated subsession: ${subsession._id}`);
    }
    
    // 2. Delete the duplicate speakers
    console.log('\nDeleting duplicate speakers...');
    
    const deletionResult = await Speaker.deleteMany({ _id: { $in: speakerIdsToDelete } });
    console.log(`Deleted ${deletionResult.deletedCount} duplicate speakers`);
    
    // 3. Verify result
    const remainingCount = await Speaker.countDocuments();
    console.log(`\nRemaining speakers: ${remainingCount}`);
    
    // Complete
    console.log('\nDuplicate speakers cleanup complete!');
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
    
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

// Confirm before running
console.log('WARNING: This script will delete 55 duplicate speaker records and update all references.');
console.log('Press Ctrl+C to abort, or wait 5 seconds to continue...');

setTimeout(() => {
  removeDuplicateSpeakers();
}, 5000); 