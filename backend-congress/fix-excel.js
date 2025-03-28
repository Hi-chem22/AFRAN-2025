const xlsx = require('xlsx');
const path = require('path');
const fs = require('fs');

// Function to generate a fixed Excel file for testing
const createFixedExcelFile = () => {
  // Create a new workbook
  const wb = xlsx.utils.book_new();
  
  // Use exactly the field names expected by the backend
  const data = [
    {
      'DayId': '67daaa87349bac58b66ad83c',
      'RoomId': '67e0abdbd899f8432337ca6c',
      'Symposium Title': 'Lunch Symposium: Innovations in Nephrology',
      'Chairperson(s)': 'Prof. John Smith, Prof. Maria Garcia',
      'Start Time': '0.5',
      'End Time': '0.625',
      'Lab Logo URL': 'https://example.com/logo1.png',
      'Subsession 1 Title': 'New Treatments for CKD',
      'Subsession 1 SpeakerIds': '67e0a86cd899f8432337c957,67e0a86cd899f8432337c954',
      'Subsession 2 Title': 'Advancements in Dialysis',
      'Subsession 2 SpeakerIds': '67e0a876d899f8432337ca32'
    },
    {
      'DayId': '67daaabc349bac58b66ad841',
      'RoomId': '67e0abdad899f8432337ca5f',
      'Symposium Title': 'Lunch Symposium: Renal Transplantation Updates',
      'Chairperson(s)': 'Prof. Ahmed Hassan',
      'Start Time': '0.5',
      'End Time': '0.625',
      'Lab Logo URL': 'https://example.com/logo2.png',
      'Subsession 1 Title': 'Immunosuppression Strategies',
      'Subsession 1 SpeakerIds': '67e0a86cd899f8432337c957',
      'Subsession 2 Title': 'Long-term Outcomes in Kidney Transplantation',
      'Subsession 2 SpeakerIds': '67e0a876d899f8432337ca35'
    }
  ];
  
  // Convert to worksheet
  const ws = xlsx.utils.json_to_sheet(data);
  
  // Add worksheet to workbook
  xlsx.utils.book_append_sheet(wb, ws, 'Lunch Symposia Test');
  
  // Create directory if it doesn't exist
  const dir = path.join(__dirname, 'uploads', 'debug');
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  // Write to file
  const filePath = path.join(dir, 'fixed-symposia-test.xlsx');
  xlsx.writeFile(wb, filePath);
  
  console.log('Fixed Excel file created at:', filePath);
  return filePath;
};

// Create the file
const fixedFilePath = createFixedExcelFile();

// Debug info
console.log('\nTo test upload with curl:');
console.log(`curl -v -F "file=@${fixedFilePath}" http://localhost:8080/api/lunch-symposia/upload`); 