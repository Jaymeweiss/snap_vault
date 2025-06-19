require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    photo = Photo.new(title: "Beautiful Sunset", description: "A stunning sunset over the mountains")
    assert photo.valid?
  end

  test "should require title" do
    photo = Photo.new(description: "A photo without title")
    assert_not photo.valid?
    assert_includes photo.errors[:title], "can't be blank"
  end

  test "should not allow title longer than 100 characters" do
    photo = Photo.new(title: "a" * 101, description: "Valid description")
    assert_not photo.valid?
    assert_includes photo.errors[:title], "is too long (maximum is 100 characters)"
  end

  test "should not allow description longer than 500 characters" do
    photo = Photo.new(title: "Valid Title", description: "a" * 501)
    assert_not photo.valid?
    assert_includes photo.errors[:description], "is too long (maximum is 500 characters)"
  end

  test "should allow empty description" do
    photo = Photo.new(title: "Valid Title", description: "")
    assert photo.valid?
  end

  test "should allow nil description" do
    photo = Photo.new(title: "Valid Title", description: nil)
    assert photo.valid?
  end
end
