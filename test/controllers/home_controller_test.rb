require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index when not authenticated" do
    get home_index_url
    assert_response :success
  end

  test "should get index when authenticated" do
    # Create a test user and log them in via JSON API
    user = users(:one) # Using fixture
    post sessions_path, 
         params: { email: user.email, password: 'password' }.to_json,
         headers: { 'Content-Type' => 'application/json' }

    get home_index_url
    assert_response :success
  end
end
