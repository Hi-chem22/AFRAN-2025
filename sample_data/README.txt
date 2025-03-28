# Creating Excel Import File

## Instructions:

1. Open Microsoft Excel or another spreadsheet application

2. Create a new workbook with two sheets:
   - Rename the first sheet to "Sessions"
   - Rename the second sheet to "Subsessions"

3. Import each CSV file into the corresponding sheet:
   - Import sessions_template.csv into the "Sessions" sheet
   - Import subsessions_template.csv into the "Subsessions" sheet

   Alternatively, you can copy and paste the contents from each CSV file.

4. Save the file as an Excel workbook (.xlsx format)

5. Use this file with the Postman import as follows:
   - POST to http://localhost:8080/api/sessions/import
   - Use form-data with key "file" and select your Excel file

## Data Structure

### Sessions Sheet:
- ID: Unique identifier for the session (optional, will be generated if missing)
- Session Title: Title of the session (required)
- Room: Name of the room (optional)
- Day: Day number (optional)
- Start Time: Format HH:MM (required)
- End Time: Format HH:MM (required)
- Chairs: Names of chairpersons, separated by commas (optional)
- Description: Session description (optional)

### Subsessions Sheet:
- Session ID: Must match an ID in the Sessions sheet (required)
- Title: Title of the subsession (required)
- Start Time: Format HH:MM (optional)
- End Time: Format HH:MM (optional)
- Speaker: Name of the speaker (optional)
- Speaker Country: Country of the speaker (optional)
- Speaker Bio: Brief bio of the speaker (optional)
- Speaker Flag: Country code for flag display (e.g., us, fr) (optional)
- Description: Subsession description (optional)

## Note:
The system will automatically:
- Create rooms and days if they don't exist
- Calculate durations from start and end times
- Create speaker entries if they don't exist 