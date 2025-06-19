class SessionsController < ApplicationController
  # Skip CSRF protection for API endpoints
  skip_before_action :verify_authenticity_token
  # Skip login requirement for sessions controller
  skip_before_action :require_login


  # POST /sessions (login)
  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      access_token = JwtService.encode(user)
      refresh_token = JwtService.encode_refresh_token(user)

      if access_token
        render json: { 
          success: true, 
          user: { id: user.id, email: user.email },
          access_token: access_token,
          refresh_token: refresh_token,
          token_type: 'Bearer',
          expires_in: 24.hours.to_i
        }, status: :ok
      else
        render json: { 
          success: false, 
          error: 'Failed to generate authentication token' 
        }, status: :internal_server_error
      end
    else
      render json: { 
        success: false, 
        error: 'Invalid email or password' 
      }, status: :unauthorized
    end
  end

  # DELETE /sessions (logout)
  def destroy
    session[:user_id] = nil
    render json: { success: true, message: 'Logged out successfully' }, status: :ok
  end

  # GET /sessions (current user)
  def show
    if current_user
      access_token = JwtService.encode(current_user)
      refresh_token = JwtService.encode_refresh_token(current_user)

      if access_token
        render json: { 
          success: true, 
          user: { id: current_user.id, email: current_user.email },
          access_token: access_token,
          refresh_token: refresh_token,
          token_type: 'Bearer',
          expires_in: 24.hours.to_i
        }, status: :ok
      else
        render json: { 
          success: false, 
          error: 'Failed to generate authentication token' 
        }, status: :internal_server_error
      end
    else
      render json: { success: false, error: 'Not authenticated' }, status: :unauthorized
    end
  end

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    nil
  end

end
