require "test_helper"

class Api::FilesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @token = "token_#{@user.id}_#{Time.current.to_i}"
    @auth_headers = { "Authorization" => "Bearer #{@token}" }
  end

  # Authentication tests
  test "should require authentication for index" do
    get api_files_url
    assert_response :unauthorized
    assert_includes response.body, "Authorization token required"
  end

  test "should require authentication for create" do
    post api_files_url
    assert_response :unauthorized
    assert_includes response.body, "Authorization token required"
  end

  test "should reject invalid token" do
    get api_files_url, headers: { "Authorization" => "Bearer invalid_token" }
    assert_response :unauthorized
    assert_includes response.body, "Invalid or expired token"
  end

  # Index action tests
  test "should get index with valid token" do
    get api_files_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_instance_of Array, json_response
  end

  test "should return user's files only" do
    # Create files for different users
    other_user = users(:two)
    user_file = @user.uploaded_files.create!(
      filename: "user_file.txt",
      size: 1024,
      content_type: "text/plain"
    )
    other_file = other_user.uploaded_files.create!(
      filename: "other_file.txt", 
      size: 2048,
      content_type: "text/plain"
    )

    get api_files_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    file_ids = json_response.map { |f| f["id"] }

    assert_includes file_ids, user_file.id
    assert_not_includes file_ids, other_file.id
  end

  test "should return files with correct structure" do
    file = @user.uploaded_files.create!(
      filename: "test_file.txt",
      size: 1024,
      content_type: "text/plain"
    )

    get api_files_url, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    file_data = json_response.first

    assert_equal file.id, file_data["id"]
    assert_equal file.filename, file_data["filename"]
    assert_equal file.size, file_data["size"]
    assert_equal file.content_type, file_data["content_type"]
    assert_not_nil file_data["created_at"]
    # download_url and preview_url will be nil without actual file attachment
  end

  # Create action tests
  test "should create file with valid data" do
    file_upload = fixture_file_upload("test_file.txt", "text/plain")

    assert_difference("UploadedFile.count", 1) do
      post api_files_url, 
           params: { file: file_upload }, 
           headers: @auth_headers
    end

    assert_response :created
    json_response = JSON.parse(response.body)

    assert_equal "test_file.txt", json_response["filename"]
    assert_not_nil json_response["id"]
    assert_not_nil json_response["size"]
    assert_equal "text/plain", json_response["content_type"]
  end

  test "should reject request without file" do
    post api_files_url, headers: @auth_headers
    assert_response :bad_request
    assert_includes response.body, "No file provided"
  end

  test "should reject file that is too large" do
    # Mock a large file
    large_file = Rack::Test::UploadedFile.new(
      StringIO.new("x" * (3 * 1024 * 1024)), # 3MB (exceeds 2MB limit)
      "text/plain",
      original_filename: "large_file.txt"
    )

    post api_files_url,
         params: { file: large_file },
         headers: @auth_headers

    assert_response :bad_request
    assert_includes response.body, "File is too large"
  end

  test "should associate file with current user" do
    file_upload = fixture_file_upload("test_file.txt", "text/plain")

    post api_files_url,
         params: { file: file_upload },
         headers: @auth_headers

    assert_response :created

    uploaded_file = UploadedFile.last
    assert_equal @user.id, uploaded_file.user_id
  end

  test "should handle validation errors" do
    # Create a file upload with invalid file type that will pass initial checks but fail validation
    file_upload = fixture_file_upload("test_file.pdf", "application/pdf")

    post api_files_url,
         params: { file: file_upload },
         headers: @auth_headers

    assert_response :bad_request
    assert_includes response.body, "File type not allowed"
  end

  private

  def fixture_file_upload(filename, content_type)
    file_path = Rails.root.join("test", "fixtures", "files", filename)

    # Create the test file if it doesn't exist
    unless File.exist?(file_path)
      FileUtils.mkdir_p(File.dirname(file_path))
      File.write(file_path, "Test file content for #{filename}")
    end

    Rack::Test::UploadedFile.new(file_path, content_type)
  end
end
