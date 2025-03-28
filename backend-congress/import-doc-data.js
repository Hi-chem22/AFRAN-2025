#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const readline = require('readline');

// Create interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// ANSI color codes for better console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  magenta: '\x1b[35m'
};

// Paths
const dataDir = path.join(__dirname, 'data');
const docxPath = path.join(dataDir, 'congress-data.docx');
const sampleTextPath = path.join(dataDir, 'sample-congress-data.txt');
const structureGuidePath = path.join(dataDir, 'document-structure-guide.txt');

// Check if the data directory exists, if not create it
if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir, { recursive: true });
  console.log(`${colors.green}✓${colors.reset} Created data directory`);
}

// Main function to guide the user through the process
async function main() {
  console.log(`\n${colors.bright}${colors.cyan}=== AFRAN 2025 Congress Data Import Tool ===${colors.reset}\n`);
  
  // Check if mammoth is installed
  try {
    require('mammoth');
    console.log(`${colors.green}✓${colors.reset} Mammoth library is installed`);
  } catch (err) {
    console.log(`${colors.yellow}!${colors.reset} Mammoth library is not installed. Installing now...`);
    await new Promise((resolve, reject) => {
      exec('npm install mammoth --save', (err, stdout, stderr) => {
        if (err) {
          console.error(`${colors.red}✗${colors.reset} Failed to install mammoth: ${err.message}`);
          reject(err);
          return;
        }
        console.log(`${colors.green}✓${colors.reset} Mammoth installed successfully`);
        resolve();
      });
    });
  }
  
  // Check if docx file exists
  if (fs.existsSync(docxPath)) {
    console.log(`${colors.green}✓${colors.reset} Found congress-data.docx file`);
    promptForAction();
  } else {
    console.log(`${colors.yellow}!${colors.reset} No congress-data.docx file found in the data directory`);
    showOptions();
  }
}

// Show options for the user
function showOptions() {
  console.log(`\n${colors.bright}Choose an option:${colors.reset}`);
  console.log(`1. View document structure guide`);
  console.log(`2. Create a sample DOCX file`);
  console.log(`3. Import your own DOCX file (must be named 'congress-data.docx')`);
  console.log(`4. Exit`);
  
  rl.question('\nEnter option number: ', (answer) => {
    switch (answer.trim()) {
      case '1':
        showDocumentStructureGuide();
        break;
      case '2':
        createSampleDocx();
        break;
      case '3':
        promptForDocxImport();
        break;
      case '4':
        exitProgram();
        break;
      default:
        console.log(`${colors.red}Invalid option.${colors.reset}`);
        showOptions();
    }
  });
}

// Show the document structure guide
function showDocumentStructureGuide() {
  if (fs.existsSync(structureGuidePath)) {
    const guide = fs.readFileSync(structureGuidePath, 'utf8');
    console.log(`\n${colors.bright}${colors.magenta}Document Structure Guide:${colors.reset}\n`);
    console.log(guide);
  } else {
    console.log(`${colors.red}✗${colors.reset} Document structure guide not found`);
    
    // If the guide doesn't exist, create it
    const guideContent = `DOCUMENT STRUCTURE GUIDE FOR CONGRESS DATA IMPORT

This guide explains how to format your Word document so that our extraction tool can parse it correctly.
The document should be organized into clear sections with specific formatting for each type of data.

====================================
GENERAL STRUCTURE
====================================

Your document should have three main sections:
1. SPEAKERS
2. SESSIONS
3. ROOMS

Each section heading should be on its own line and in ALL CAPS.

====================================
SPEAKERS SECTION
====================================

Format each speaker as follows:

Name: [Speaker's full name]
Country: [Country of origin]
Bio: [Short biography]
Image: [Image filename or URL, optional]

====================================
SESSIONS SECTION
====================================

Format each session as follows:

Title: [Session title]
Day: [Day number, e.g., 1, 2, 3]
Start: [Start time, e.g., 09:00]
End: [End time, e.g., 10:30]
Description: [Session description]
Room: [Room name - must match a room in the ROOMS section]
Speaker: [Speaker name - must match a name in the SPEAKERS section]
Speaker: [Another speaker if applicable]

To add subsessions:

Subsession: [Subsession title]
SubDescription: [Subsession description]
SubSpeaker: [Speaker name for this subsession]

====================================
ROOMS SECTION
====================================

Format each room as follows:

Name: [Room name]
Capacity: [Number of seats]
Location: [Location description, e.g., "First Floor, North Wing"]`;
    
    fs.writeFileSync(structureGuidePath, guideContent);
    console.log(`${colors.green}✓${colors.reset} Created document structure guide`);
    console.log(`\n${colors.bright}${colors.magenta}Document Structure Guide:${colors.reset}\n`);
    console.log(guideContent);
  }
  
  rl.question('\nPress Enter to continue...', () => {
    showOptions();
  });
}

// Create a sample DOCX file
function createSampleDocx() {
  console.log(`\n${colors.yellow}Creating sample DOCX file...${colors.reset}`);
  
  // Check if the sample text exists
  if (!fs.existsSync(sampleTextPath)) {
    console.log(`${colors.yellow}!${colors.reset} Sample text file not found, creating it...`);
    
    // Create sample text content
    const sampleContent = `SPEAKERS

Name: Dr. Ahmed Benali
Country: Morocco
Bio: Professor of Neurology at Rabat University with extensive experience in neurological disorders.
Image: ahmed_benali.jpg

Name: Pr. Sophie Martin
Country: France
Bio: Leading researcher in cardiology at Paris-Sorbonne University.
Image: sophie_martin.jpg

SESSIONS

Title: Opening Ceremony: AFRAN 2025
Day: 1
Start: 09:00
End: 10:00
Description: Welcome to the 2025 African Medical Research and Applications Network Congress.
Room: Grand Ballroom
Speaker: Dr. Ahmed Benali
Speaker: Pr. Sophie Martin

Title: Advances in Neurological Research
Day: 1
Start: 10:30
End: 12:30
Description: This session will cover the latest findings in neurological research.
Room: Salle A
Speaker: Dr. Ahmed Benali
Subsession: Cognitive Disorders in Rural Areas
SubDescription: Examination of cognitive disorders prevalent in rural African communities
SubSpeaker: Dr. Ahmed Benali

ROOMS

Name: Grand Ballroom
Capacity: 500
Location: Ground Floor, Main Building

Name: Salle A
Capacity: 200
Location: First Floor, East Wing`;
    
    fs.writeFileSync(sampleTextPath, sampleContent);
    console.log(`${colors.green}✓${colors.reset} Created sample text file`);
  }
  
  // Check if docx library is installed
  try {
    require('docx');
    console.log(`${colors.green}✓${colors.reset} DOCX library is installed`);
  } catch (err) {
    console.log(`${colors.yellow}!${colors.reset} DOCX library is not installed. Installing now...`);
    exec('npm install docx --save', (err, stdout, stderr) => {
      if (err) {
        console.error(`${colors.red}✗${colors.reset} Failed to install docx: ${err.message}`);
        return;
      }
      console.log(`${colors.green}✓${colors.reset} DOCX library installed successfully`);
      convertTextToDocx();
    });
    return;
  }
  
  // Convert the text file to DOCX
  convertTextToDocx();
}

// Convert text to DOCX
function convertTextToDocx() {
  try {
    const { Document, Packer, Paragraph } = require('docx');
    
    // Read the sample text file
    const sampleText = fs.readFileSync(sampleTextPath, 'utf8');
    
    // Split the text into lines
    const lines = sampleText.split('\n');
    
    // Create a new document
    const doc = new Document();
    
    // Add each line as a paragraph to the document
    const children = lines.map(line => new Paragraph({ text: line }));
    
    doc.addSection({
      properties: {},
      children: children
    });
    
    // Generate the DOCX file
    Packer.toBuffer(doc).then((buffer) => {
      fs.writeFileSync(docxPath, buffer);
      console.log(`${colors.green}✓${colors.reset} Sample DOCX file created at: data/congress-data.docx`);
      promptForAction();
    }).catch(err => {
      console.error(`${colors.red}✗${colors.reset} Error creating DOCX file: ${err.message}`);
      showOptions();
    });
  } catch (err) {
    console.error(`${colors.red}✗${colors.reset} Error: ${err.message}`);
    showOptions();
  }
}

// Prompt for DOCX import
function promptForDocxImport() {
  console.log(`\n${colors.yellow}!${colors.reset} To import your own data, place your DOCX file in the following location:`);
  console.log(`${colors.cyan}${docxPath}${colors.reset}`);
  console.log(`\nMake sure your document follows the structure guide (option 1).`);
  
  rl.question('\nHave you placed your DOCX file in the correct location? (y/n): ', (answer) => {
    if (answer.toLowerCase() === 'y') {
      if (fs.existsSync(docxPath)) {
        console.log(`${colors.green}✓${colors.reset} Found congress-data.docx file`);
        promptForAction();
      } else {
        console.log(`${colors.red}✗${colors.reset} File not found. Please place your DOCX file in the data directory.`);
        showOptions();
      }
    } else {
      showOptions();
    }
  });
}

// Prompt for action
function promptForAction() {
  console.log(`\n${colors.bright}Choose an action:${colors.reset}`);
  console.log(`1. Extract data from DOCX and insert into MongoDB`);
  console.log(`2. Return to main menu`);
  console.log(`3. Exit`);
  
  rl.question('\nEnter action number: ', (answer) => {
    switch (answer.trim()) {
      case '1':
        extractAndImportData();
        break;
      case '2':
        showOptions();
        break;
      case '3':
        exitProgram();
        break;
      default:
        console.log(`${colors.red}Invalid option.${colors.reset}`);
        promptForAction();
    }
  });
}

// Extract and import data
function extractAndImportData() {
  console.log(`\n${colors.yellow}Starting data extraction and import process...${colors.reset}`);
  
  // Run the extraction script
  exec('node extract-doc.js', (err, stdout, stderr) => {
    if (err) {
      console.error(`${colors.red}✗${colors.reset} Error during extraction: ${err.message}`);
      console.log(`\n${colors.red}Error output:${colors.reset}\n${stderr}`);
      
      rl.question('\nPress Enter to return to the main menu...', () => {
        showOptions();
      });
      return;
    }
    
    console.log(stdout);
    console.log(`${colors.green}✓${colors.reset} Data extraction and import completed successfully!`);
    
    rl.question('\nPress Enter to return to the main menu...', () => {
      showOptions();
    });
  });
}

// Exit the program
function exitProgram() {
  console.log(`\n${colors.bright}${colors.green}Thank you for using the AFRAN 2025 Congress Data Import Tool!${colors.reset}`);
  rl.close();
  process.exit(0);
}

// Start the program
main().catch(err => {
  console.error(`${colors.red}✗${colors.reset} Error: ${err.message}`);
  process.exit(1);
}); 