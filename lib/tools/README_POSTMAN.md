# AFRAN 2025 API Testing with Postman

This guide provides instructions for testing the sponsor-related APIs using Postman.

## Setup Instructions

1. **Import the Collection**:
   - Open Postman
   - Click "Import" button in the top left
   - Select the `postman_collection_sponsors.json` file
   - The collection "AFRAN 2025 - Sponsors API" will be imported

2. **Environment Setup**:
   - Create a new Environment in Postman
   - Add a variable called `sponsorId` (leave it empty for now)
   - Save the environment and select it

## Testing the API Endpoints

### 1. Get All Sponsors
- Select the "Get All Sponsors" request
- Click "Send"
- You should see a JSON array of sponsors (empty if none exist yet)

### 2. Create a Sponsor
- Select the "Create Sponsor" request
- The request body is pre-filled with sample data:
  ```json
  {
    "name": "AFRAN Gold Sponsor",
    "rank": "Gold",
    "imageUrl": "https://example.com/sponsor-logo.png"
  }
  ```
- Click "Send"
- Note the `_id` field in the response - this is the sponsor ID

### 3. Set the Sponsor ID
- In the Postman environment, set the `sponsorId` variable to the ID from step 2
- Click "Save" to save the environment

### 4. Get a Specific Sponsor
- Select the "Get Sponsor by ID" request
- Click "Send"
- You should see the specific sponsor details

### 5. Update a Sponsor
- Select the "Update Sponsor" request
- Modify any fields in the request body
- Click "Send"
- You should see the updated sponsor in the response

### 6. Delete a Sponsor
- Select the "Delete Sponsor" request
- Click "Send"
- Confirm the sponsor has been deleted by running "Get All Sponsors" again

## Sponsor JSON Structure

Here's the structure of a sponsor object:

```json
{
  "_id": "auto-generated-id",
  "name": "Sponsor Name",
  "rank": "Gold|Silver|Bronze|Platinum|Diamond",
  "imageUrl": "https://path-to-sponsor-image.png",
  "createdAt": "2024-03-19T12:00:00.000Z"
}
```

### Field Descriptions:
- `name` (required): String - The name of the sponsor
- `rank` (required): String - The sponsor's rank (must be one of: Gold, Silver, Bronze, Platinum, Diamond)
- `imageUrl` (required): String - URL to the sponsor's image/logo
- `createdAt`: Date - Automatically set when the sponsor is created

## API Endpoints Summary

- **GET** `/api/sponsors` - Get all sponsors
- **POST** `/api/sponsors` - Create a new sponsor
- **GET** `/api/sponsors/:id` - Get a specific sponsor
- **PUT** `/api/sponsors/:id` - Update a sponsor
- **DELETE** `/api/sponsors/:id` - Delete a sponsor

## Backend Server

These endpoints assume the backend server is running at `http://localhost:8080`. If your server is running on a different host or port, update the URLs in the Postman collection accordingly. 