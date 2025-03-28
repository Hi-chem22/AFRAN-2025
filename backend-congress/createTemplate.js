const path = require('path');
const fs = require('fs');
const xlsx = require('xlsx');

// Create a function to generate a sample template
const createSampleTemplate = () => {
  // Create a new workbook
  const wb = xlsx.utils.book_new();
  
  // Sample data with instructions and column headers
  const symposiaSheet = [
    [
      'Lunch Symposia Import Template - Instructions:',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      ''
    ],
    [
      '1. Fill in all required (*) fields',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      ''
    ],
    [
      '2. Don\'t change the column headers or sheet structure',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      ''
    ],
    [
      '3. Each row represents one lunch symposium with exactly 2 subsessions',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      ''
    ],
    [
      '4. All lunch symposia must have exactly 2 subsessions',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      ''
    ],
    [
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      ''
    ],
    [
      'DayId*',
      'RoomId*',
      'Symposium Title*',
      'Chairperson(s)',
      'Start Time*',
      'End Time*',
      'Lab Logo URL',
      'Subsession 1 Title*',
      'Subsession 1 SpeakerIds',
      'Subsession 2 Title*',
      'Subsession 2 SpeakerIds'
    ],
    [
      '67daaa87349bac58b66ad83c',
      '67e0abdbd899f8432337ca6c',
      'Lunch Symposium: New Approaches in Nephrology',
      'Prof. John Smith, Prof. Maria Garcia',
      '0.5',
      '0.625',
      'https://example.com/logo.png',
      'New Biomarkers for Kidney Disease',
      '67e0a86cd899f8432337c957,67e0a86cd899f8432337c954',
      'Advances in Dialysis Technology',
      '67e0a876d899f8432337ca32'
    ],
    [
      '67daaabc349bac58b66ad841',
      '67e0abdad899f8432337ca5f',
      'Lunch Symposium: Renal Transplantation Updates',
      'Prof. Ahmed Hassan',
      '0.5',
      '0.625',
      'https://example.com/logo2.png',
      'Immunosuppression Strategies',
      '67e0a86cd899f8432337c957',
      'Long-term Outcomes in Kidney Transplantation',
      '67e0a876d899f8432337ca35'
    ]
  ];
  
  // Add explanation sheet
  const explanationSheet = [
    ['Field', 'Description', 'Format', 'Example'],
    ['DayId', 'MongoDB ID of the conference day', 'String (ObjectId)', '67daaa87349bac58b66ad83c (Tuesday)'],
    ['RoomId', 'MongoDB ID of the room', 'String (ObjectId)', '67e0abdbd899f8432337ca6c (Pr. Hassouna BEN AYED Conference Hall)'],
    ['Symposium Title', 'Title of the lunch symposium', 'Text', 'Lunch Symposium: Advances in Nephrology'],
    ['Chairperson(s)', 'Name(s) of the chairperson(s)', 'Text', 'Prof. John Smith, Prof. Maria Garcia OR Prof. Ahmed Hassan'],
    ['Start Time', 'Start time in decimal format (0-1)', 'Decimal', '0.5 (equivalent to 12:00)'],
    ['End Time', 'End time in decimal format (0-1)', 'Decimal', '0.625 (equivalent to 15:00)'],
    ['Lab Logo URL', 'URL to the laboratory/company logo', 'URL', 'https://company.com/logo.png'],
    ['Subsession 1 Title', 'Title of the first talk/presentation', 'Text', 'New Approaches in CKD Management'],
    ['Subsession 1 SpeakerIds', 'MongoDB IDs of speakers for first subsession', 'String (comma-separated ObjectIds)', '67e0a86cd899f8432337c957,67e0a86cd899f8432337c954'],
    ['Subsession 2 Title', 'Title of the second talk/presentation', 'Text', 'Advances in Dialysis Technology'],
    ['Subsession 2 SpeakerIds', 'MongoDB IDs of speakers for second subsession', 'String (comma-separated ObjectIds)', '67e0a876d899f8432337ca32'],
    ['', '', '', ''],
    ['Time Conversion', 'Decimal to Time', '', ''],
    ['0.5', '12:00', '', ''],
    ['0.5208', '12:30', '', ''],
    ['0.5417', '13:00', '', ''],
    ['0.5625', '13:30', '', ''],
    ['0.5833', '14:00', '', ''],
    ['0.6042', '14:30', '', ''],
    ['0.625', '15:00', '', '']
  ];
  
  // Add reference sheet with days, rooms, and sample speakers
  const referenceSheet = [
    ['Available Days:', '', ''],
    ['DayId', 'Day Number', 'Day Name'],
    ['67daaa87349bac58b66ad83c', '1', 'Tuesday'],
    ['67daaabc349bac58b66ad841', '2', 'Wednesday'],
    ['67daac49349bac58b66ad845', '3', 'Thursday'],
    ['', '', ''],
    ['Available Rooms:', '', ''],
    ['RoomId', 'Room Name', ''],
    ['67e0abdbd899f8432337ca6c', 'Pr. Hassouna BEN AYED Conference Hall', ''],
    ['67e0abdad899f8432337ca5f', 'Pr. Adel KHEDHER Conference Room', ''],
    ['67e0adead88f9dbce65b5e7b', 'Pr. Abdelhamid JARRAYA Conference Room', ''],
    ['', '', ''],
    ['Sample Speakers:', '', ''],
    ['SpeakerId', 'Speaker Name', 'Country'],
    ['67e0a86cd899f8432337c957', 'Marcello TONELLI', 'Canada'],
    ['67e0a86cd899f8432337c954', 'Gloria ASHUNTANTANG', 'Cameroon'],
    ['67e0a876d899f8432337ca32', 'Rumeyza KAZANCIOGLU', 'Turkey'],
    ['67e0a876d899f8432337ca35', 'Robert KALYESUBULA', 'Uganda']
  ];
  
  // Convert to worksheets
  const wsData = xlsx.utils.aoa_to_sheet(symposiaSheet);
  const wsExplanation = xlsx.utils.aoa_to_sheet(explanationSheet);
  const wsReference = xlsx.utils.aoa_to_sheet(referenceSheet);
  
  // Set column widths for main data sheet
  wsData['!cols'] = [
    { width: 30 }, // DayId
    { width: 30 }, // RoomId
    { width: 40 }, // Symposium Title
    { width: 40 }, // Chairperson(s)
    { width: 12 }, // Start Time
    { width: 12 }, // End Time
    { width: 40 }, // Lab Logo URL
    { width: 40 }, // Subsession 1 Title
    { width: 50 }, // Subsession 1 SpeakerIds
    { width: 40 }, // Subsession 2 Title
    { width: 50 }  // Subsession 2 SpeakerIds
  ];
  
  // Set column widths for explanation sheet
  wsExplanation['!cols'] = [
    { width: 20 }, // Field
    { width: 40 }, // Description
    { width: 30 }, // Format
    { width: 40 }  // Example
  ];
  
  // Set column widths for reference sheet
  wsReference['!cols'] = [
    { width: 30 }, // Id
    { width: 40 }, // Name
    { width: 20 }  // Additional Info
  ];
  
  // Add worksheets to workbook
  xlsx.utils.book_append_sheet(wb, wsData, 'Lunch Symposia');
  xlsx.utils.book_append_sheet(wb, wsExplanation, 'Field Explanations');
  xlsx.utils.book_append_sheet(wb, wsReference, 'Reference Data');
  
  // Create directory if it doesn't exist
  const dir = path.join(__dirname, 'uploads', 'templates');
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  // Write to file
  const templatePath = path.join(dir, 'lunch-symposia-template.xlsx');
  xlsx.writeFile(wb, templatePath);
  
  console.log('Sample template created at: ' + templatePath);
};

// Execute the function
createSampleTemplate(); 