# Grantmaking MVP Backend

This is a minimum viable product (MVP) backend in Ruby for a collaborative grantmaking platform.

## Features
- Built with Ruby and Sinatra for a lightweight, fast MVP.
- Implements 5 RESTful API endpoints.
- Populated with realistic, hardcoded mock data focusing on grants, organizations, and platform metrics.

## Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Run the server:
   ```bash
   ruby app.rb
   # or
   rackup
   ```
   The server will start at `http://localhost:4567` (if using `ruby app.rb`) or `http://localhost:9292` (if using `rackup`).

## API Endpoints

### 1. List Grants
**GET** `/api/v1/grants`
Returns a list of all grant records on the platform.

**Example Request:**
```bash
curl -X GET http://localhost:9292/api/v1/grants
```

**Example Response:**
```json
{
  "success": true,
  "count": 3,
  "data": [
    {
      "id": "g-1001",
      "title": "Global Clean Water Initiative",
      "description": "Funding for water purification systems in rural communities.",
      "amount_requested": 250000.0,
      "amount_awarded": 250000.0,
      "status": "Active",
      "grantee_organization_id": "org-200",
      "funder_organization_id": "org-100",
      "start_date": "2024-01-15",
      "end_date": "2025-01-14"
    }
  ]
}
```

### 2. Get Grant Details
**GET** `/api/v1/grants/:id`
Returns detailed information for a specific grant ID (e.g., `g-1001`).

**Example Request:**
```bash
curl -X GET http://localhost:9292/api/v1/grants/g-1001
```

**Example Response:**
```json
{
  "success": true,
  "data": {
    "id": "g-1001",
    "title": "Global Clean Water Initiative",
    "description": "Funding for water purification systems in rural communities.",
    "amount_requested": 250000.0,
    "amount_awarded": 250000.0,
    "status": "Active",
    "grantee_organization_id": "org-200",
    "funder_organization_id": "org-100",
    "start_date": "2024-01-15",
    "end_date": "2025-01-14"
  }
}
```

### 3. Submit a Grant Application
**POST** `/api/v1/grants`
Accepts a JSON payload to submit a new grant application.

**Example Request:**
```bash
curl -X POST http://localhost:9292/api/v1/grants \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Community Garden Expansion",
    "description": "Funding to expand our urban garden by 2 acres.",
    "amount_requested": 15000,
    "grantee_organization_id": "org-201",
    "funder_organization_id": "org-100"
  }'
```

**Example Response:**
```json
{
  "success": true,
  "message": "Grant application submitted successfully.",
  "data": {
    "id": "g-8472",
    "title": "Community Garden Expansion",
    "description": "Funding to expand our urban garden by 2 acres.",
    "amount_requested": 15000,
    "amount_awarded": null,
    "status": "Submitted",
    "grantee_organization_id": "org-201",
    "funder_organization_id": "org-100",
    "start_date": null,
    "end_date": null
  }
}
```

### 4. List Organizations
**GET** `/api/v1/organizations`
Returns a list of funders and grantees. Supports optional query parameter `?type=Funder` or `?type=Grantee`.

**Example Request:**
```bash
curl -X GET "http://localhost:9292/api/v1/organizations?type=Funder"
```

**Example Response:**
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": "org-100",
      "name": "The Gates Foundation",
      "type": "Funder",
      "location": "Seattle, WA"
    },
    {
      "id": "org-101",
      "name": "Green Earth Trust",
      "type": "Funder",
      "location": "San Francisco, CA"
    }
  ]
}
```

### 5. Platform Metrics
**GET** `/api/v1/metrics`
Returns high-level statistics for a dashboard, such as total funding awarded and active grants.

**Example Request:**
```bash
curl -X GET http://localhost:9292/api/v1/metrics
```

**Example Response:**
```json
{
  "success": true,
  "data": {
    "total_active_grants": 1,
    "total_funding_awarded": 370000.0,
    "organizations_on_platform": 5,
    "upcoming_deadlines": 12,
    "platform_uptime": "99.99%"
  }
}
```
