require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  # POST /sessions (login) tests
  test "should login with valid credentials" do
    user = users(:one)

    post sessions_path, params: {
      email: user.email,
      password: 'password'
    }, as: :json

    assert_response :ok

    response_data = JSON.parse(response.body)
    assert response_data['success']
    assert_equal user.id, response_data['user']['id']
    assert_equal user.email, response_data['user']['email']
    assert_not_nil response_data['access_token']
    assert_not_nil response_data['refresh_token']
    assert_equal 'Bearer', response_data['token_type']
    assert_equal 24.hours.to_i, response_data['expires_in']

    # Verify JWT token format (3 parts separated by dots)
    assert_equal 3, response_data['access_token'].split('.').length

    # Verify session was set
    assert_equal user.id, session[:user_id]
  end

  test "should login with case insensitive email" do
    user = users(:one)

    post sessions_path, params: {
      email: user.email.upcase,
      password: 'password'
    }, as: :json

    assert_response :ok

    response_data = JSON.parse(response.body)
    assert response_data['success']
    assert_equal user.id, response_data['user']['id']
  end

  test "should not login with invalid email" do
    post sessions_path, params: {
      email: 'nonexistent@example.com',
      password: 'password'
    }, as: :json

    assert_response :unauthorized

    response_data = JSON.parse(response.body)
    assert_not response_data['success']
    assert_equal 'Invalid email or password', response_data['error']
    assert_nil session[:user_id]
  end

  test "should not login with invalid password" do
    user = users(:one)

    post sessions_path, params: {
      email: user.email,
      password: 'wrongpassword'
    }, as: :json

    assert_response :unauthorized

    response_data = JSON.parse(response.body)
    assert_not response_data['success']
    assert_equal 'Invalid email or password', response_data['error']
    assert_nil session[:user_id]
  end

  test "should not login with missing email" do
    post sessions_path, params: {
      password: 'password'
    }, as: :json

    assert_response :unauthorized

    response_data = JSON.parse(response.body)
    assert_not response_data['success']
    assert_equal 'Invalid email or password', response_data['error']
  end

  test "should not login with missing password" do
    user = users(:one)

    post sessions_path, params: {
      email: user.email
    }, as: :json

    assert_response :unauthorized

    response_data = JSON.parse(response.body)
    assert_not response_data['success']
    assert_equal 'Invalid email or password', response_data['error']
  end

  # DELETE /sessions (logout) tests
  test "should logout successfully" do
    user = users(:one)

    # First login
    post sessions_path, params: {
      email: user.email,
      password: 'password'
    }, as: :json

    # Then logout
    delete sessions_path, as: :json

    assert_response :ok

    response_data = JSON.parse(response.body)
    assert response_data['success']
    assert_equal 'Logged out successfully', response_data['message']
    assert_nil session[:user_id]
  end

  test "should logout even when not logged in" do
    delete sessions_path, as: :json

    assert_response :ok

    response_data = JSON.parse(response.body)
    assert response_data['success']
    assert_equal 'Logged out successfully', response_data['message']
  end

  # GET /sessions (current user) tests
  test "should show current user when logged in" do
    user = users(:one)

    # Login first
    post sessions_path, params: {
      email: user.email,
      password: 'password'
    }, as: :json

    # Then get current user
    get sessions_path, as: :json

    assert_response :ok

    response_data = JSON.parse(response.body)
    assert response_data['success']
    assert_equal user.id, response_data['user']['id']
    assert_equal user.email, response_data['user']['email']
    assert_not_nil response_data['access_token']
    assert_not_nil response_data['refresh_token']
    assert_equal 'Bearer', response_data['token_type']
    assert_equal 24.hours.to_i, response_data['expires_in']

    # Verify JWT token format (3 parts separated by dots)
    assert_equal 3, response_data['access_token'].split('.').length
  end

  test "should return unauthorized when not logged in" do
    get sessions_path, as: :json

    assert_response :unauthorized

    response_data = JSON.parse(response.body)
    assert_not response_data['success']
    assert_equal 'Not authenticated', response_data['error']
  end

  test "should handle invalid session user_id gracefully" do
    user = users(:one)

    # First login to set session
    post sessions_path, params: {
      email: user.email,
      password: 'password'
    }, as: :json

    assert_response :ok

    # Now delete the user from database to simulate invalid user_id in session
    user.destroy

    # Try to get current user - should handle the missing user gracefully
    get sessions_path, as: :json

    assert_response :unauthorized

    response_data = JSON.parse(response.body)
    assert_not response_data['success']
    assert_equal 'Not authenticated', response_data['error']
  end
end
