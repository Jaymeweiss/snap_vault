class UploadedFile < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  # Allowed file types
  ALLOWED_CONTENT_TYPES = [
    'image/jpeg',
    'image/png', 
    'image/gif',
    'image/svg+xml',
    'text/plain',
    'text/markdown',
    'text/csv'
  ].freeze

  ALLOWED_EXTENSIONS = %w[.jpg .jpeg .png .gif .svg .txt .md .csv].freeze

  validates :filename, presence: true
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :content_type, presence: true

  # Maximum file size: 2MB
  validates :size, numericality: { less_than_or_equal_to: 2.megabytes }

  # Validate file type by content type
  validates :content_type, inclusion: { 
    in: ALLOWED_CONTENT_TYPES, 
    message: "must be one of the following types: #{ALLOWED_EXTENSIONS.join(', ')}" 
  }

  # Validate file extension
  validate :allowed_file_extension

  def download_url
    Rails.application.routes.url_helpers.rails_blob_path(file, disposition: "attachment", only_path: true) if file.attached?
  end

  def preview_url
    return nil unless file.attached?
    return nil unless content_type&.start_with?('image/')

    Rails.application.routes.url_helpers.rails_representation_path(
      file.variant(resize_to_limit: [200, 200]), 
      disposition: "inline",
      only_path: true
    )
  end

  private

  def allowed_file_extension
    return unless filename.present?

    extension = File.extname(filename).downcase
    unless ALLOWED_EXTENSIONS.include?(extension)
      errors.add(:filename, "must have one of the following extensions: #{ALLOWED_EXTENSIONS.join(', ')}")
    end
  end
end
