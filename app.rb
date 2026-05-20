require 'sinatra'
require 'json'

# --- Mock Data ---

# This is a collaborative grantmaking platform.
# We need data for grants, organizations, users, and applications.

GRANTS = [
  { 
    id: "g-1001", 
    title: "Global Clean Water Initiative", 
    description: "Funding for water purification systems in rural communities.",
    amount_requested: 250000.00,
    amount_awarded: 250000.00,
    status: "Active", 
    grantee_organization_id: "org-200",
    funder_organization_id: "org-100",
    start_date: "2024-01-15",
    end_date: "2025-01-14"
  },
  { 
    id: "g-1002", 
    title: "Urban Education Excellence", 
    description: "Supporting STEM education in inner-city schools.",
    amount_requested: 150000.00,
    amount_awarded: 120000.00,
    status: "Closed", 
    grantee_organization_id: "org-201",
    funder_organization_id: "org-100",
    start_date: "2023-05-01",
    end_date: "2024-04-30"
  },
  { 
    id: "g-1003", 
    title: "Renewable Energy Research", 
    description: "Early stage research grant for next-gen solar panels.",
    amount_requested: 500000.00,
    amount_awarded: nil,
    status: "Under Review", 
    grantee_organization_id: "org-202",
    funder_organization_id: "org-101",
    start_date: nil,
    end_date: nil
  }
]

ORGANIZATIONS = [
  { id: "org-100", name: "The Gates Foundation", type: "Funder", location: "Seattle, WA" },
  { id: "org-101", name: "Green Earth Trust", type: "Funder", location: "San Francisco, CA" },
  { id: "org-200", name: "Water For All NGO", type: "Grantee", location: "Nairobi, Kenya" },
  { id: "org-201", name: "City Schools Alliance", type: "Grantee", location: "Chicago, IL" },
  { id: "org-202", name: "Solar Innovators Lab", type: "Grantee", location: "Austin, TX" }
]

# Configure Sinatra to return JSON for all routes
before do
  content_type :json
end

# Default route
get '/' do
  { 
    message: "Welcome to the Grantmaking API MVP",
    endpoints: [
      "GET /api/v1/grants",
      "GET /api/v1/grants/:id",
      "POST /api/v1/grants",
      "GET /api/v1/organizations",
      "GET /api/v1/organizations/:id",
      "GET /api/v1/metrics"
    ]
  }.to_json
end

# 1. GET /api/v1/grants
# Retrieve a list of all grants.
get '/api/v1/grants' do
  status 200
  {
    success: true,
    count: GRANTS.length,
    data: GRANTS
  }.to_json
end

# 2. GET /api/v1/grants/:id
# Retrieve details of a specific grant by its ID.
get '/api/v1/grants/:id' do
  grant = GRANTS.find { |g| g[:id] == params[:id] }
  
  if grant
    status 200
    {
      success: true,
      data: grant
    }.to_json
  else
    status 404
    {
      success: false,
      error: "Grant not found with ID: #{params[:id]}"
    }.to_json
  end
end

# 3. POST /api/v1/grants
# Create a new grant application (mocked - doesn't actually persist).
post '/api/v1/grants' do
  begin
    request.body.rewind
    payload = JSON.parse(request.body.read)
    
    # Generate a fake ID and simulate creation
    new_grant = {
      id: "g-#{rand(1004..9999)}",
      title: payload['title'] || "Untitled Grant",
      description: payload['description'] || "",
      amount_requested: payload['amount_requested'],
      amount_awarded: nil,
      status: "Submitted",
      grantee_organization_id: payload['grantee_organization_id'],
      funder_organization_id: payload['funder_organization_id'],
      start_date: nil,
      end_date: nil
    }
    
    status 201
    {
      success: true,
      message: "Grant application submitted successfully.",
      data: new_grant
    }.to_json
  rescue JSON::ParserError
    status 400
    {
      success: false,
      error: "Invalid JSON payload provided."
    }.to_json
  end
end

# 4. GET /api/v1/organizations
# Retrieve a list of all organizations (funders and grantees).
get '/api/v1/organizations' do
  # Optional filtering by type
  type_filter = params['type']
  
  orgs = ORGANIZATIONS
  if type_filter
    orgs = ORGANIZATIONS.select { |o| o[:type].downcase == type_filter.downcase }
  end
  
  status 200
  {
    success: true,
    count: orgs.length,
    data: orgs
  }.to_json
end

# 5. GET /api/v1/organizations/:id
# Retrieve details of a specific organization by its ID, including related grants.
get '/api/v1/organizations/:id' do
  org = ORGANIZATIONS.find { |o| o[:id] == params[:id] }
  
  if org
    # Fetch related grants for this organization
    org_grants = GRANTS.select { |g| g[:funder_organization_id] == params[:id] || g[:grantee_organization_id] == params[:id] }
    
    status 200
    {
      success: true,
      data: org.merge(grants: org_grants)
    }.to_json
  else
    status 404
    {
      success: false,
      error: "Organization not found with ID: #{params[:id]}"
    }.to_json
  end
end

# 6. GET /api/v1/metrics
# Retrieve high-level platform metrics for a dashboard.
get '/api/v1/metrics' do
  # Calculate some fake but realistic metrics based on our mock data
  total_funding = GRANTS.map { |g| g[:amount_awarded].to_f }.sum
  
  status 200
  {
    success: true,
    data: {
      total_active_grants: GRANTS.count { |g| g[:status] == 'Active' },
      total_funding_awarded: total_funding,
      organizations_on_platform: ORGANIZATIONS.length,
      upcoming_deadlines: 12,
      platform_uptime: "99.99%"
    }
  }.to_json
end
