const xlsx = require('xlsx');
const path = require('path');
const fs = require('fs');

// Function to generate an Excel template for lunch symposia
const generateTemplate = () => {
  // Create a new workbook
  const wb = xlsx.utils.book_new();
  
  // Create example data with all required fields
  const exampleData = [
    {
      // Required fields
      'DayId': '67daaa87349bac58b66ad83c', // MongoDB ObjectId for the Day
      'RoomId': '67e0abdbd899f8432337ca6c', // MongoDB ObjectId for the Room
      'Symposium Title': 'Example: Advances in Nephrology Treatment',
      'Start Time': '0.5', // Decimal representing time (0.5 = 12:00)
      'End Time': '0.625', // Decimal representing time (0.625 = 15:00)
      
      // Optional fields
      'Chairperson(s)': 'Prof. Example Name, Dr. Second Chair',
      'Lab Logo URL': 'https://example.com/logo.png',
      
      // Subsession 1 (required)
      'Subsession 1 Title': 'Example: New Treatments for CKD',
      'Subsession 1 SpeakerIds': '67e0a86cd899f8432337c957,67e0a86cd899f8432337c954', // Comma-separated MongoDB ObjectIds
      
      // Subsession 2 (required)
      'Subsession 2 Title': 'Example: Advancements in Dialysis',
      'Subsession 2 SpeakerIds': '67e0a876d899f8432337ca32' // MongoDB ObjectId
    }
  ];
  
  // Add a blank row as template for users to fill in
  const templateRow = {
    'DayId': '',
    'RoomId': '',
    'Symposium Title': '',
    'Start Time': '',
    'End Time': '',
    'Chairperson(s)': '',
    'Lab Logo URL': '',
    'Subsession 1 Title': '',
    'Subsession 1 SpeakerIds': '',
    'Subsession 2 Title': '',
    'Subsession 2 SpeakerIds': ''
  };
  
  // Combine example with template row
  const templateData = [...exampleData, templateRow];
  
  // Convert to worksheet
  const ws = xlsx.utils.json_to_sheet(templateData);
  
  // Add some styling information and column width instructions
  // This is basic styling, XLSX doesn't support full Excel styling
  const wscols = [
    { wch: 24 }, // DayId
    { wch: 24 }, // RoomId
    { wch: 40 }, // Symposium Title
    { wch: 15 }, // Start Time
    { wch: 15 }, // End Time
    { wch: 30 }, // Chairperson(s)
    { wch: 40 }, // Lab Logo URL
    { wch: 40 }, // Subsession 1 Title
    { wch: 50 }, // Subsession 1 SpeakerIds
    { wch: 40 }, // Subsession 2 Title
    { wch: 50 }, // Subsession 2 SpeakerIds
  ];
  
  ws['!cols'] = wscols;
  
  // Add worksheet to workbook
  xlsx.utils.book_append_sheet(wb, ws, 'Lunch Symposia Template');
  
  // Create directory if it doesn't exist
  const dir = path.join(__dirname, 'uploads', 'templates');
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  // Write to file
  const filePath = path.join(dir, 'lunch-symposia-template.xlsx');
  xlsx.writeFile(wb, filePath);
  
  console.log('Template file created at:', filePath);
  return filePath;
};

// Run the generator
generateTemplate();

console.log('\nTemplate generated. You can now download it from:');
console.log('http://localhost:8080/api/lunch-symposia/template'); 