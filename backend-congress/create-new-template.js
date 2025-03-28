const xlsx = require('xlsx');
const path = require('path');
const fs = require('fs');

// Function to generate a more flexible Excel template for lunch symposia
function generateTemplate() {
  // Create a new workbook
  const wb = xlsx.utils.book_new();
  
  // Create example data with all required fields and optional second subsession
  const exampleData = [
    {
      // Required fields
      'DayId': '67daaa87349bac58b66ad83c', // MongoDB ObjectId for the Day
      'RoomId': '67e0abdbd899f8432337ca6c', // MongoDB ObjectId for the Room
      'Symposium Title': 'Lunch Symposium: Company Name',
      'Start Time': '0.5', // Decimal representing time (0.5 = 12:00)
      'End Time': '0.625', // Decimal representing time (0.625 = 15:00)
      
      // Optional fields
      'Chairperson(s)': 'Prof. Example Name, Dr. Second Chair',
      'Lab Logo URL': 'https://example.com/logo.png',
      
      // Required first subsession
      'Subsession 1 Title': 'Topic of First Presentation',
      'Subsession 1 SpeakerIds': '67e1f08d5aedc6fe4bb3046f',
      
      // Optional second subsession
      'Subsession 2 Title': 'Topic of Second Presentation (Optional)',
      'Subsession 2 SpeakerIds': '67e1f2a05aedc6fe4bb30470'
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
    'Subsession 2 Title': '(Optional)',
    'Subsession 2 SpeakerIds': ''
  };
  
  // Combine example with template row
  const templateData = [...exampleData, templateRow];
  
  // Convert to worksheet
  const ws = xlsx.utils.json_to_sheet(templateData);
  
  // Add some comments/headers to explain required vs optional fields
  const headerComment = 'Fields marked with * are required. Subsession 2 is optional.';
  // Note: xlsx doesn't easily support rich comments, so this is basic documentation
  
  // Add worksheet to workbook
  xlsx.utils.book_append_sheet(wb, ws, 'Lunch Symposia Template');
  
  // Create directory if it doesn't exist
  const templatesDir = path.join(__dirname, 'uploads', 'templates');
  if (!fs.existsSync(templatesDir)) {
    fs.mkdirSync(templatesDir, { recursive: true });
  }
  
  // Write to file
  const templatePath = path.join(templatesDir, 'lunch-symposia-template.xlsx');
  xlsx.writeFile(wb, templatePath);
  console.log('New template file created at:', templatePath);
  
  console.log('\nYou can download the template from:');
  console.log('http://localhost:8080/api/lunch-symposia/template');
  
  console.log('\nNOTE: Subsession 2 is now optional. If not provided, a default title will be used.');
  
  return templatePath;
}

// Run the generator
generateTemplate(); 