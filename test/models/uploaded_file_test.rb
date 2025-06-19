require "test_helper"

class UploadedFileTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @uploaded_file = UploadedFile.new(
      filename: "test.txt",
      size: 1024,
      content_type: "text/plain",
      user: @user
    )
  end

  test "should be valid with valid attributes" do
    assert @uploaded_file.valid?
  end

  test "should require filename" do
    @uploaded_file.filename = nil
    assert_not @uploaded_file.valid?
    assert_includes @uploaded_file.errors[:filename], "can't be blank"
  end

  test "should require size" do
    @uploaded_file.size = nil
    assert_not @uploaded_file.valid?
    assert_includes @uploaded_file.errors[:size], "can't be blank"
  end

  test "should require positive size" do
    @uploaded_file.size = 0
    assert_not @uploaded_file.valid?
    assert_includes @uploaded_file.errors[:size], "must be greater than 0"
  end

  test "should require content_type" do
    @uploaded_file.content_type = nil
    assert_not @uploaded_file.valid?
    assert_includes @uploaded_file.errors[:content_type], "can't be blank"
  end

  test "should require user" do
    @uploaded_file.user = nil
    assert_not @uploaded_file.valid?
    assert_includes @uploaded_file.errors[:user], "must exist"
  end

  test "should reject files larger than 2MB" do
    @uploaded_file.size = 3.megabytes
    assert_not @uploaded_file.valid?
    assert_includes @uploaded_file.errors[:size], "must be less than or equal to 2097152"
  end

  test "should accept files up to 2MB" do
    @uploaded_file.size = 2.megabytes
    assert @uploaded_file.valid?
  end

  test "should accept valid file types" do
    valid_types = [
      { filename: "test.jpg", content_type: "image/jpeg" },
      { filename: "test.png", content_type: "image/png" },
      { filename: "test.gif", content_type: "image/gif" },
      { filename: "test.svg", content_type: "image/svg+xml" },
      { filename: "test.txt", content_type: "text/plain" },
      { filename: "test.md", content_type: "text/markdown" },
      { filename: "test.csv", content_type: "text/csv" }
    ]

    valid_types.each do |type|
      @uploaded_file.filename = type[:filename]
      @uploaded_file.content_type = type[:content_type]
      assert @uploaded_file.valid?, "Should accept #{type[:filename]} with content type #{type[:content_type]}"
    end
  end

  test "should reject invalid file types by content type" do
    invalid_types = [
      { filename: "test.pdf", content_type: "application/pdf" },
      { filename: "test.doc", content_type: "application/msword" },
      { filename: "test.exe", content_type: "application/octet-stream" }
    ]

    invalid_types.each do |type|
      @uploaded_file.filename = type[:filename]
      @uploaded_file.content_type = type[:content_type]
      assert_not @uploaded_file.valid?, "Should reject #{type[:filename]} with content type #{type[:content_type]}"
      assert_includes @uploaded_file.errors[:content_type], "must be one of the following types: .jpg, .jpeg, .png, .gif, .svg, .txt, .md, .csv"
    end
  end

  test "should reject invalid file extensions" do
    invalid_extensions = [
      "test.pdf",
      "test.doc", 
      "test.exe",
      "test.zip"
    ]

    invalid_extensions.each do |filename|
      @uploaded_file.filename = filename
      @uploaded_file.content_type = "text/plain" # Valid content type but invalid extension
      assert_not @uploaded_file.valid?, "Should reject filename #{filename}"
      assert_includes @uploaded_file.errors[:filename], "must have one of the following extensions: .jpg, .jpeg, .png, .gif, .svg, .txt, .md, .csv"
    end
  end

  test "should belong to user" do
    assert_equal @user, @uploaded_file.user
  end

  test "download_url should return nil without attached file" do
    uploaded_file = uploaded_files(:one)
    assert_nil uploaded_file.download_url
  end

  test "preview_url should return nil without attached file" do
    uploaded_file = uploaded_files(:one)
    assert_nil uploaded_file.preview_url
  end

  test "preview_url should return nil for non-image files" do
    uploaded_file = uploaded_files(:one)
    uploaded_file.content_type = "text/plain"
    assert_nil uploaded_file.preview_url
  end

  test "should have Active Storage attachment" do
    assert_respond_to @uploaded_file, :file
  end

  test "user should have many uploaded_files" do
    assert_respond_to @user, :uploaded_files
    assert_equal UploadedFile, @user.uploaded_files.build.class
  end

  test "should destroy uploaded_files when user is destroyed" do
    user = User.create!(email: "test@example.com", password: "password")
    uploaded_file = user.uploaded_files.create!(
      filename: "test.txt",
      size: 1024,
      content_type: "text/plain"
    )

    assert_difference("UploadedFile.count", -1) do
      user.destroy
    end
  end
end
