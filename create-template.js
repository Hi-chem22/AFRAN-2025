const XLSX = require('xlsx');
const path = require('path');
const fs = require('fs');

// Create a new workbook
const wb = XLSX.utils.book_new();

// Create Sessions sheet
const sessionData = [
  {
    'ID': 1,
    'Session Title': 'Main Session Example',
    'Room': 'Room A',
    'Day': 1,
    'Start Time': '09:00',
    'End Time': '12:00',
    'Chairs': 'Dr. John Doe, Dr. Jane Smith',
    'Description': 'This is a main session description',
    'Speaker IDs': '67db3c536f2c0b5e95ca920c,67e01030eb931f01c3a92490'
  }
];
const wsSession = XLSX.utils.json_to_sheet(sessionData);
XLSX.utils.book_append_sheet(wb, wsSession, 'Sessions');

// Create Subsessions sheet
const subsessionData = [
  {
    'Session ID': 1,
    'Title': 'Subsession 1',
    'Start Time': '09:00',
    'End Time': '10:00',
    'Speaker': 'Dr. John Doe',
    'Speaker Country': 'USA',
    'Speaker Bio': 'Professor at University XYZ',
    'Speaker Flag': 'us',
    'Description': 'This is a subsession description',
    'Speaker IDs': '67db3c536f2c0b5e95ca920c,67e01030eb931f01c3a92490'
  },
  {
    'Session ID': 1,
    'Title': 'Subsession 2',
    'Start Time': '10:00',
    'End Time': '11:00',
    'Speaker': 'Dr. Jane Smith',
    'Speaker Country': 'UK',
    'Speaker Bio': 'Researcher at Institute ABC',
    'Speaker Flag': 'gb',
    'Description': 'Another subsession description',
    'Speaker IDs': '67e01030eb931f01c3a92491,67e01030eb931f01c3a92492'
  }
];
const wsSubsession = XLSX.utils.json_to_sheet(subsessionData);
XLSX.utils.book_append_sheet(wb, wsSubsession, 'Subsessions');

// Create Subsubsessions sheet
const subsubsessionData = [
  {
    'Session ID': 1,
    'Subsession Title': 'Subsession 1',
    'Title': 'Subsubsession 1A',
    'Start Time': '09:00',
    'End Time': '09:30',
    'Description': 'First part of the subsession',
    'Speaker IDs': '67db3c536f2c0b5e95ca920c'
  },
  {
    'Session ID': 1,
    'Subsession Title': 'Subsession 1',
    'Title': 'Subsubsession 1B',
    'Start Time': '09:30',
    'End Time': '10:00',
    'Description': 'Second part of the subsession',
    'Speaker IDs': '67e01030eb931f01c3a92490'
  },
  {
    'Session ID': 1,
    'Subsession Title': 'Subsession 2',
    'Title': 'Subsubsession 2A',
    'Start Time': '10:00',
    'End Time': '10:30',
    'Description': 'First part of the second subsession',
    'Speaker IDs': '67e01030eb931f01c3a92491'
  },
  {
    'Session ID': 1,
    'Subsession Title': 'Subsession 2',
    'Title': 'Subsubsession 2B',
    'Start Time': '10:30',
    'End Time': '11:00',
    'Description': 'Second part of the second subsession',
    'Speaker IDs': '67e01030eb931f01c3a92492'
  }
];
const wsSubsubsession = XLSX.utils.json_to_sheet(subsubsessionData);
XLSX.utils.book_append_sheet(wb, wsSubsubsession, 'Subsubsessions');

// Write the workbook to a file
const filename = path.join(process.cwd(), 'session-template-with-subsubsessions.xlsx');
XLSX.writeFile(wb, filename);

console.log(`Excel template created: ${filename}`); 