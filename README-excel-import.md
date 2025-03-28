# Excel Import Format for Sessions

## Overview
This guide describes the format required for Excel files to import sessions and subsessions into the system.

## File Structure
The Excel file should contain two sheets:
1. `Sessions` - Contains details about the main sessions
2. `Subsessions` - Contains details about subsessions linked to main sessions

## Sessions Sheet Columns
The Sessions sheet must include the following columns:

| Column Name | Description | Required | Example |
|-------------|-------------|----------|---------|
| ID | Unique identifier for the session (used to link subsessions) | Yes | 1 |
| Session Title | The title of the session | Yes | "Keynote Address" |
| Room | Name of the room (will create if doesn't exist) | No | "Main Hall" |
| Room ID | MongoDB ID of an existing room | No | "67daa6dc79d1c8e1ee65e87c" |
| Day | Day number | No | 1 |
| Day ID | MongoDB ID of an existing day | No | "67daa6dc79d1c8e1ee65e87e" |
| Start Time | Start time of the session | No | "09:00" |
| End Time | End time of the session | No | "10:30" |
| Chairs | Comma-separated names of chairpersons | No | "Dr. John Smith, Dr. Jane Doe" |
| Description | Session description | No | "Opening keynote of the conference" |
| Speaker IDs | Comma-separated MongoDB IDs of speakers | No | "644a1e4b1d7bd86fca76c52e,644a1e4b1d7bd86fca76c52f" |

Note: Either provide `Room` or `Room ID`, and either `Day` or `Day ID`. If both are provided, the ID will take precedence.

## Subsessions Sheet Columns
The Subsessions sheet must include the following columns:

| Column Name | Description | Required | Example |
|-------------|-------------|----------|---------|
| Session ID | ID from the Sessions sheet to link the subsession | Yes | 1 |
| Title | Title of the subsession | Yes | "Introduction to AI" |
| Start Time | Start time of the subsession | No | "09:00" |
| End Time | End time of the subsession | No | "09:30" |
| Speaker | Name of the speaker | No | "Dr. John Smith" |
| Speaker Country | Speaker's country | No | "France" |
| Speaker Bio | Speaker's bio | No | "Professor of Computer Science" |
| Speaker Flag | Country code for flag | No | "fr" |
| Description | Subsession description | No | "An introduction to AI concepts" |
| Speaker IDs | Comma-separated MongoDB IDs of speakers | No | "644a1e4b1d7bd86fca76c52e" |

## Sample Format
A sample Excel file would look like:

### Sessions Sheet:
- ID, Session Title, Room ID, Day ID, Start Time, End Time, Chairs, Description, Speaker IDs
- 1, "Keynote Address", "67daa6dc79d1c8e1ee65e87c", "67daa6dc79d1c8e1ee65e87e", "09:00", "10:30", "Dr. Smith", "Opening keynote", "644a1e4b1d7bd86fca76c52e"

### Subsessions Sheet:
- Session ID, Title, Start Time, End Time, Speaker, Speaker Country, Speaker Bio, Speaker Flag, Description, Speaker IDs
- 1, "AI Introduction", "09:00", "09:30", "Dr. Smith", "France", "Professor", "fr", "Introduction to AI", "644a1e4b1d7bd86fca76c52e"

## API Endpoint
Upload the Excel file to:
```
POST http://localhost:8080/api/sessions/import
```

Make sure to send the file as form-data with the key name "file".

Example using curl:
```bash
curl -X POST -F "file=@sessions.xlsx" http://localhost:8080/api/sessions/import
```

Example using Postman:
1. Create a new POST request to http://localhost:8080/api/sessions/import
2. In the "Body" tab, select "form-data"
3. Add a key named "file" and change its type to "File"
4. Select your Excel file
5. Click "Send" 