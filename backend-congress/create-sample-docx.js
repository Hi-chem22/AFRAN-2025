const fs = require('fs');
const path = require('path');
const { Document, Packer, Paragraph } = require('docx');

// Path to the sample text file
const sampleTextPath = path.join(__dirname, 'data', 'sample-congress-data.txt');
// Path where the DOCX file will be saved
const outputDocxPath = path.join(__dirname, 'data', 'congress-data.docx');

// Read the sample text file
const sampleText = fs.readFileSync(sampleTextPath, 'utf8');

// Split the text into lines
const lines = sampleText.split('\n');

// Create a new document
const doc = new Document();

// Add each line as a paragraph to the document
lines.forEach(line => {
  doc.addSection({
    properties: {},
    children: [
      new Paragraph({
        text: line,
      }),
    ],
  });
});

// Generate the DOCX file
Packer.toBuffer(doc).then((buffer) => {
  fs.writeFileSync(outputDocxPath, buffer);
  console.log(`✅ DOCX file created at: ${outputDocxPath}`);
}).catch(err => {
  console.error('❌ Error creating DOCX file:', err);
}); 