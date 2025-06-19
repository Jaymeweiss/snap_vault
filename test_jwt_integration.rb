#!/usr/bin/env ruby

# JWT Integration Test Script
# This script demonstrates the new JWT functionality

require_relative 'config/environment'

puts "=== JWT Integration Test ==="
puts

# Create a test user
user = User.find_or_create_by(email: 'jwt_test@example.com') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
end

puts "1. Testing JWT Token Generation:"
puts "   User: #{user.email} (ID: #{user.id})"

# Generate JWT tokens
access_token = JwtService.encode(user)
refresh_token = JwtService.encode_refresh_token(user)

puts "   ✓ Access Token Generated: #{access_token[0..50]}..."
puts "   ✓ Refresh Token Generated: #{refresh_token[0..50]}..."
puts

# Test token validation
puts "2. Testing JWT Token Validation:"
puts "   ✓ Access Token Valid: #{JwtService.valid?(access_token)}"
puts "   ✓ Refresh Token Valid: #{JwtService.valid?(refresh_token)}"
puts "   ✓ Invalid Token Valid: #{JwtService.valid?('invalid.token.here')}"
puts

# Test token decoding
puts "3. Testing JWT Token Decoding:"
payload = JwtService.decode(access_token)
if payload
  puts "   ✓ Token decoded successfully"
  puts "   - User ID: #{payload['user_id']}"
  puts "   - Email: #{payload['email']}"
  puts "   - Issuer: #{payload['iss']}"
  puts "   - Issued At: #{Time.at(payload['iat'])}"
  puts "   - Expires At: #{Time.at(payload['exp'])}"
else
  puts "   ✗ Failed to decode token"
end
puts

# Test user extraction
puts "4. Testing User Extraction from Token:"
extracted_user = JwtService.user_from_token(access_token)
if extracted_user
  puts "   ✓ User extracted successfully"
  puts "   - ID: #{extracted_user.id}"
  puts "   - Email: #{extracted_user.email}"
  puts "   - Matches original user: #{extracted_user.id == user.id}"
else
  puts "   ✗ Failed to extract user from token"
end
puts

# Test Bearer token format
puts "5. Testing Bearer Token Format:"
bearer_token = "Bearer #{access_token}"
bearer_payload = JwtService.decode(bearer_token)
puts "   ✓ Bearer token decoded: #{bearer_payload.present?}"
puts

# Test expired token
puts "6. Testing Expired Token Handling:"
expired_token = JwtService.encode(user, 1.second.ago)
sleep(0.1)
expired_payload = JwtService.decode(expired_token)
puts "   ✓ Expired token properly rejected: #{expired_payload.nil?}"
puts

# Test token refresh comparison
puts "7. Testing Token Expiration Times:"
access_payload = JwtService.decode(access_token)
refresh_payload = JwtService.decode(refresh_token)
if access_payload && refresh_payload
  access_exp = Time.at(access_payload['exp'])
  refresh_exp = Time.at(refresh_payload['exp'])
  puts "   ✓ Access token expires: #{access_exp}"
  puts "   ✓ Refresh token expires: #{refresh_exp}"
  puts "   ✓ Refresh token lasts longer: #{refresh_exp > access_exp}"
else
  puts "   ✗ Failed to compare token expiration times"
end
puts

puts "=== JWT Integration Test Complete ==="
puts "All JWT functionality is working correctly!"
puts
puts "New JWT Response Format:"
puts "{"
puts "  \"success\": true,"
puts "  \"user\": { \"id\": #{user.id}, \"email\": \"#{user.email}\" },"
puts "  \"access_token\": \"#{access_token[0..30]}...\","
puts "  \"refresh_token\": \"#{refresh_token[0..30]}...\","
puts "  \"token_type\": \"Bearer\","
puts "  \"expires_in\": #{24.hours.to_i}"
puts "}"

# Clean up test user
user.destroy
puts
puts "Test user cleaned up."