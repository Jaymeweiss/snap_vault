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
      render json: { 
        success: true, 
        user: { id: user.id, email: user.email },
        token: generate_token(user)
      }, status: :ok
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
      render json: { 
        success: true, 
        user: { id: current_user.id, email: current_user.email },
        token: generate_token(current_user)
      }, status: :ok
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

  def generate_token(user)
    # Simple token generation - in production, use JWT or similar
    "token_#{user.id}_#{Time.current.to_i}"
  end
end
