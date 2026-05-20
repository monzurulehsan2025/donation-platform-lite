require File.expand_path '../app.rb', __dir__
require 'rspec'
require 'rack/test'

ENV['APP_ENV'] = 'test'

RSpec.describe 'Grantmaking API' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe 'GET /' do
    it 'returns the root endpoints list' do
      get '/'
      expect(last_response).to be_ok
      response = JSON.parse(last_response.body)
      expect(response['message']).to eq('Welcome to the Grantmaking API MVP')
      expect(response['endpoints'].length).to eq(6)
    end
  end

  describe 'GET /api/v1/grants' do
    it 'returns all grants' do
      get '/api/v1/grants'
      expect(last_response).to be_ok
      response = JSON.parse(last_response.body)
      expect(response['success']).to be true
      expect(response['data']).to be_an(Array)
      expect(response['count']).to eq(3)
    end
  end

  describe 'GET /api/v1/grants/:id' do
    it 'returns details for a valid grant ID' do
      get '/api/v1/grants/g-1001'
      expect(last_response).to be_ok
      response = JSON.parse(last_response.body)
      expect(response['success']).to be true
      expect(response['data']['id']).to eq('g-1001')
      expect(response['data']['title']).to eq('Global Clean Water Initiative')
    end

    it 'returns 404 for an invalid grant ID' do
      get '/api/v1/grants/invalid-id'
      expect(last_response.status).to eq(404)
      response = JSON.parse(last_response.body)
      expect(response['success']).to be false
    end
  end

  describe 'POST /api/v1/grants' do
    it 'creates a new grant with valid JSON payload' do
      payload = {
        title: 'New Test Grant',
        description: 'Test Description',
        amount_requested: 50000,
        grantee_organization_id: 'org-200',
        funder_organization_id: 'org-100'
      }

      post '/api/v1/grants', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(201)
      response = JSON.parse(last_response.body)
      expect(response['success']).to be true
      expect(response['data']['title']).to eq('New Test Grant')
      expect(response['data']['status']).to eq('Submitted')
      expect(response['data']['id']).to start_with('g-')
    end

    it 'returns 400 for invalid JSON' do
      post '/api/v1/grants', "invalid json", { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(400)
    end
  end

  describe 'GET /api/v1/organizations' do
    it 'returns all organizations' do
      get '/api/v1/organizations'
      expect(last_response).to be_ok
      response = JSON.parse(last_response.body)
      expect(response['success']).to be true
      expect(response['data']).to be_an(Array)
      expect(response['count']).to eq(5)
    end

    it 'filters organizations by type' do
      get '/api/v1/organizations?type=funder'
      expect(last_response).to be_ok
      response = JSON.parse(last_response.body)
      expect(response['count']).to eq(2)
      expect(response['data'].all? { |o| o['type'] == 'Funder' }).to be true
    end
  end

  describe 'GET /api/v1/organizations/:id' do
    it 'returns details for a valid organization ID' do
      get '/api/v1/organizations/org-100'
      expect(last_response).to be_ok
      response = JSON.parse(last_response.body)
      expect(response['success']).to be true
      expect(response['data']['id']).to eq('org-100')
      expect(response['data']['name']).to eq('The Gates Foundation')
      expect(response['data']['grants']).to be_an(Array)
    end

    it 'returns 404 for an invalid organization ID' do
      get '/api/v1/organizations/invalid-org'
      expect(last_response.status).to eq(404)
    end
  end

  describe 'GET /api/v1/metrics' do
    it 'returns platform metrics' do
      get '/api/v1/metrics'
      expect(last_response).to be_ok
      response = JSON.parse(last_response.body)
      expect(response['success']).to be true
      expect(response['data']).to have_key('total_active_grants')
      expect(response['data']).to have_key('total_funding_awarded')
    end
  end
end
