const xlsx = require('xlsx');
const path = require('path');
const fs = require('fs');

// Debug Excel parsing
const debugExcelParsing = () => {
  // Path to our fixed test file
  const filePath = path.join(__dirname, 'uploads', 'debug', 'fixed-symposia-test.xlsx');
  
  console.log('Reading Excel file:', filePath);
  console.log('File exists:', fs.existsSync(filePath));
  
  // Read the Excel file
  const workbook = xlsx.readFile(filePath);
  console.log('Sheets in workbook:', workbook.SheetNames);
  
  const sheet = workbook.Sheets[workbook.SheetNames[0]];
  
  // Try parsing with different options to see what works
  console.log('\n1. Parse with default options:');
  const data1 = xlsx.utils.sheet_to_json(sheet);
  console.log(JSON.stringify(data1, null, 2));
  
  console.log('\n2. Parse with range = 1 (skip header):');
  const data2 = xlsx.utils.sheet_to_json(sheet, { range: 1 });
  console.log(JSON.stringify(data2, null, 2));
  
  console.log('\n3. Parse with header row = 0:');
  const data3 = xlsx.utils.sheet_to_json(sheet, { header: 1, range: 0 });
  console.log(JSON.stringify(data3, null, 2));
  
  // Create a debugging version with more explicit field names
  console.log('\n\nCreating debugging version with explicit field names...');
  
  // Use explicit field names without spaces or special characters
  const debugData = [
    {
      DayId: '67daaa87349bac58b66ad83c',
      RoomId: '67e0abdbd899f8432337ca6c',
      SymposiumTitle: 'Lunch Symposium: Innovations in Nephrology',
      Chairpersons: 'Prof. John Smith, Prof. Maria Garcia',
      StartTime: '0.5',
      EndTime: '0.625',
      LabLogoUrl: 'https://example.com/logo1.png',
      Subsession1Title: 'New Treatments for CKD',
      Subsession1SpeakerIds: '67e0a86cd899f8432337c957,67e0a86cd899f8432337c954',
      Subsession2Title: 'Advancements in Dialysis',
      Subsession2SpeakerIds: '67e0a876d899f8432337ca32'
    },
    {
      DayId: '67daaabc349bac58b66ad841',
      RoomId: '67e0abdad899f8432337ca5f',
      SymposiumTitle: 'Lunch Symposium: Renal Transplantation Updates',
      Chairpersons: 'Prof. Ahmed Hassan',
      StartTime: '0.5',
      EndTime: '0.625',
      LabLogoUrl: 'https://example.com/logo2.png',
      Subsession1Title: 'Immunosuppression Strategies',
      Subsession1SpeakerIds: '67e0a86cd899f8432337c957',
      Subsession2Title: 'Long-term Outcomes in Kidney Transplantation',
      Subsession2SpeakerIds: '67e0a876d899f8432337ca35'
    }
  ];
  
  // Convert to worksheet
  const ws = xlsx.utils.json_to_sheet(debugData);
  
  // Create a new workbook
  const wb = xlsx.utils.book_new();
  xlsx.utils.book_append_sheet(wb, ws, 'Debug Sheet');
  
  // Write to file
  const debugFilePath = path.join(__dirname, 'uploads', 'debug', 'debug-symposia-test.xlsx');
  xlsx.writeFile(wb, debugFilePath);
  
  console.log('Debug Excel file created at:', debugFilePath);
  console.log(`\nTry uploading with:\ncurl -v -F "file=@${debugFilePath}" http://localhost:8080/api/lunch-symposia/upload`);
  
  return debugFilePath;
};

// Run the debug function
debugExcelParsing(); 