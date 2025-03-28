const path = require('path');
const fs = require('fs');
const xlsx = require('xlsx');

// Create a function to generate a Postman test template
const createPostmanTestTemplate = () => {
  // Create a new workbook
  const wb = xlsx.utils.book_new();
  
  // Sample data with real test data for Postman
  const symposiaSheet = [
    [
      'DayId',
      'RoomId',
      'Symposium Title',
      'Chairperson(s)',
      'Start Time',
      'End Time',
      'Lab Logo URL',
      'Subsession 1 Title',
      'Subsession 1 SpeakerIds',
      'Subsession 2 Title',
      'Subsession 2 SpeakerIds'
    ],
    [
      '67daaa87349bac58b66ad83c',
      '67e0abdbd899f8432337ca6c',
      'Lunch Symposium: Innovations in Nephrology',
      'Prof. John Smith, Prof. Maria Garcia',
      '0.5',
      '0.625',
      'https://example.com/logo1.png',
      'New Treatments for CKD',
      '67e0a86cd899f8432337c957,67e0a86cd899f8432337c954',
      'Advancements in Dialysis',
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
  
  // Convert to worksheets
  const wsData = xlsx.utils.aoa_to_sheet(symposiaSheet);
  
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
  
  // Add worksheet to workbook
  xlsx.utils.book_append_sheet(wb, wsData, 'Lunch Symposia Test');
  
  // Create directory if it doesn't exist
  const dir = path.join(__dirname, 'uploads', 'postman');
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  // Write to file
  const templatePath = path.join(dir, 'lunch-symposia-postman-test.xlsx');
  xlsx.writeFile(wb, templatePath);
  
  console.log('Postman test Excel file created at: ' + templatePath);
};

// Execute the function
createPostmanTestTemplate(); 