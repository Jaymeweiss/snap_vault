require 'test_helper'

class JwtServiceTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  test "should encode a valid JWT token" do
    token = JwtService.encode(@user)

    assert_not_nil token
    assert token.is_a?(String)
    assert token.split('.').length == 3 # JWT has 3 parts separated by dots
  end

  test "should decode a valid JWT token" do
    token = JwtService.encode(@user)
    payload = JwtService.decode(token)

    assert_not_nil payload
    assert_equal @user.id, payload['user_id']
    assert_equal @user.email, payload['email']
    assert_equal 'snapvault', payload['iss']
    assert payload['exp'].present?
    assert payload['iat'].present?
  end

  test "should return nil for invalid token" do
    invalid_token = "invalid.token.here"
    payload = JwtService.decode(invalid_token)

    assert_nil payload
  end

  test "should return nil for blank token" do
    payload = JwtService.decode("")
    assert_nil payload

    payload = JwtService.decode(nil)
    assert_nil payload
  end

  test "should handle Bearer prefix in token" do
    token = JwtService.encode(@user)
    bearer_token = "Bearer #{token}"
    payload = JwtService.decode(bearer_token)

    assert_not_nil payload
    assert_equal @user.id, payload['user_id']
  end

  test "should validate token correctly" do
    token = JwtService.encode(@user)

    assert JwtService.valid?(token)
    assert_not JwtService.valid?("invalid.token")
    assert_not JwtService.valid?("")
    assert_not JwtService.valid?(nil)
  end

  test "should extract user from valid token" do
    token = JwtService.encode(@user)
    extracted_user = JwtService.user_from_token(token)

    assert_not_nil extracted_user
    assert_equal @user.id, extracted_user.id
    assert_equal @user.email, extracted_user.email
  end

  test "should return nil when extracting user from invalid token" do
    extracted_user = JwtService.user_from_token("invalid.token")
    assert_nil extracted_user
  end

  test "should return nil when user does not exist" do
    token = JwtService.encode(@user)
    @user.destroy

    extracted_user = JwtService.user_from_token(token)
    assert_nil extracted_user
  end

  test "should generate refresh token with longer expiration" do
    refresh_token = JwtService.encode_refresh_token(@user)
    payload = JwtService.decode(refresh_token)

    assert_not_nil refresh_token
    assert_not_nil payload
    assert_equal @user.id, payload['user_id']

    # Refresh token should have longer expiration than regular token
    regular_token = JwtService.encode(@user)
    regular_payload = JwtService.decode(regular_token)

    assert payload['exp'] > regular_payload['exp']
  end

  test "should handle expired tokens" do
    # Create a token that expires immediately
    expired_token = JwtService.encode(@user, 1.second.ago)

    sleep(0.1) # Small delay to ensure expiration

    payload = JwtService.decode(expired_token)
    assert_nil payload

    assert_not JwtService.valid?(expired_token)

    extracted_user = JwtService.user_from_token(expired_token)
    assert_nil extracted_user
  end

  test "should return nil when encoding fails" do
    # Test with invalid user object (nil)
    token = JwtService.encode(nil)
    assert_nil token
  end

  test "should handle JWT decode errors gracefully" do
    # Test with malformed token
    malformed_token = "not.a.jwt"
    payload = JwtService.decode(malformed_token)
    assert_nil payload
  end

  test "should use correct algorithm and secret" do
    token = JwtService.encode(@user)

    # Manually decode to verify algorithm and secret
    decoded = JWT.decode(token, JwtService::SECRET_KEY, true, { algorithm: 'HS256' })
    payload = decoded.first

    assert_equal @user.id, payload['user_id']
    assert_equal 'snapvault', payload['iss']
  end

  test "should include all required payload fields" do
    token = JwtService.encode(@user)
    payload = JwtService.decode(token)

    assert payload.key?('user_id')
    assert payload.key?('email')
    assert payload.key?('exp')
    assert payload.key?('iat')
    assert payload.key?('iss')

    assert_equal @user.id, payload['user_id']
    assert_equal @user.email, payload['email']
    assert_equal 'snapvault', payload['iss']
  end
end
