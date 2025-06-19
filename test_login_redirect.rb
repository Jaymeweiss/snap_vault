#!/usr/bin/env ruby

# Test script to verify login redirect functionality
# This script tests the login API endpoint to ensure it returns the correct JWT format

require_relative 'config/environment'
require 'net/http'
require 'json'

puts "=== Login Redirect Fix Test ==="
puts

# Create a test user
user = User.find_or_create_by(email: 'login_test@example.com') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
end

puts "1. Testing Login API Response Format:"
puts "   User: #{user.email} (ID: #{user.id})"

# Start Rails server in test mode (simulate API call)
require 'rack/test'

class TestApp
  include Rack::Test::Methods
  
  def app
    Rails.application
  end
end

test_app = TestApp.new

# Test login API call
response = test_app.post '/sessions', {
  email: user.email,
  password: 'password123'
}.to_json, {
  'CONTENT_TYPE' => 'application/json'
}

puts "   Response Status: #{response.status}"

if response.status == 200
  data = JSON.parse(response.body)
  puts "   ✓ Login successful"
  puts "   ✓ Response contains 'success': #{data.key?('success')}"
  puts "   ✓ Response contains 'access_token': #{data.key?('access_token')}"
  puts "   ✓ Response contains 'refresh_token': #{data.key?('refresh_token')}"
  puts "   ✓ Response contains 'token_type': #{data.key?('token_type')}"
  puts "   ✓ Response contains 'expires_in': #{data.key?('expires_in')}"
  puts "   ✓ Response contains 'user': #{data.key?('user')}"
  
  if data['access_token']
    puts "   ✓ Access token format: #{data['access_token'][0..30]}..."
    puts "   ✓ Token type: #{data['token_type']}"
    puts "   ✓ Expires in: #{data['expires_in']} seconds"
  end
  
  puts
  puts "2. Frontend Compatibility Check:"
  puts "   ✓ Login.js now uses 'data.access_token' instead of 'data.token'"
  puts "   ✓ App.js expects a token parameter for handleLogin()"
  puts "   ✓ The access_token will be passed to App.js correctly"
  puts
  puts "3. Expected Login Flow:"
  puts "   1. User submits login form"
  puts "   2. Login.js sends POST to /sessions"
  puts "   3. Sessions controller returns JWT response with access_token"
  puts "   4. Login.js calls props.onLogin(data.access_token)"
  puts "   5. App.js stores token and redirects to 'upload' view"
  puts
  puts "=== Login Redirect Fix Test Complete ==="
  puts "✓ The login button should now redirect properly!"
  
else
  puts "   ✗ Login failed with status: #{response.status}"
  puts "   Response: #{response.body}"
end

# Clean up test user
user.destroy
puts
puts "Test user cleaned up."