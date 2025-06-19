class Api::FilesController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_login
  before_action :authenticate_user!

  # GET /api/files
  def index
    files = current_user.uploaded_files.order(created_at: :desc)

    render json: files.map { |file|
      {
        id: file.id,
        filename: file.filename,
        size: file.size,
        content_type: file.content_type,
        created_at: file.created_at,
        download_url: file.download_url,
        preview_url: file.preview_url
      }
    }
  end

  # POST /api/files
  def create
    uploaded_file = params[:file]

    if uploaded_file.blank?
      render json: { error: 'No file provided' }, status: :bad_request
      return
    end

    # Check file size (2MB limit)
    if uploaded_file.size > 2.megabytes
      render json: { error: 'File is too large. Maximum size allowed is 2MB.' }, status: :bad_request
      return
    end

    # Check file type by extension
    filename = uploaded_file.original_filename
    extension = File.extname(filename).downcase
    allowed_extensions = %w[.jpg .jpeg .png .gif .svg .txt .md .csv]

    unless allowed_extensions.include?(extension)
      render json: { error: "File type not allowed. Allowed types: #{allowed_extensions.join(', ')}" }, status: :bad_request
      return
    end

    file_record = current_user.uploaded_files.build(
      filename: uploaded_file.original_filename,
      size: uploaded_file.size,
      content_type: uploaded_file.content_type
    )

    file_record.file.attach(uploaded_file)

    if file_record.save
      render json: { 
        filename: file_record.filename,
        id: file_record.id,
        size: file_record.size,
        content_type: file_record.content_type,
        upload_timestamp: file_record.created_at
      }, status: :created
    else
      render json: { error: file_record.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_user!
    token = request.headers['Authorization']

    if token.blank?
      render json: { error: 'Authorization token required' }, status: :unauthorized
      return
    end

    # Use JWT service to extract user from token
    @current_user = JwtService.user_from_token(token)

    unless @current_user
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
