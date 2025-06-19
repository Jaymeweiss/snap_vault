class JwtService
  # JWT secret key - in production, this should be stored securely
  SECRET_KEY = Rails.application.credentials.secret_key_base || Rails.application.secret_key_base

  # Default token expiration time (24 hours)
  DEFAULT_EXPIRATION = 24.hours.from_now

  class << self
    # Generate a JWT token for a user
    # @param user [User] The user object
    # @param expiration [Time] Token expiration time (optional)
    # @return [String] JWT token
    def encode(user, expiration = DEFAULT_EXPIRATION)
      payload = {
        user_id: user.id,
        email: user.email,
        exp: expiration.to_i,
        iat: Time.current.to_i,
        iss: 'snapvault' # issuer
      }

      JWT.encode(payload, SECRET_KEY, 'HS256')
    rescue StandardError => e
      Rails.logger.error "JWT encoding error: #{e.message}"
      nil
    end

    # Decode and verify a JWT token
    # @param token [String] JWT token
    # @return [Hash, nil] Decoded payload or nil if invalid
    def decode(token)
      return nil if token.blank?

      # Remove 'Bearer ' prefix if present
      token = token.gsub(/^Bearer\s+/, '')

      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
      decoded.first
    rescue JWT::ExpiredSignature
      Rails.logger.warn "JWT token expired"
      nil
    rescue JWT::DecodeError => e
      Rails.logger.warn "JWT decode error: #{e.message}"
      nil
    rescue StandardError => e
      Rails.logger.error "JWT verification error: #{e.message}"
      nil
    end

    # Verify if a token is valid and not expired
    # @param token [String] JWT token
    # @return [Boolean] true if valid, false otherwise
    def valid?(token)
      decode(token).present?
    end

    # Extract user from token
    # @param token [String] JWT token
    # @return [User, nil] User object or nil if invalid
    def user_from_token(token)
      payload = decode(token)
      return nil unless payload

      User.find_by(id: payload['user_id'])
    rescue ActiveRecord::RecordNotFound
      nil
    end

    # Generate a refresh token (longer expiration)
    # @param user [User] The user object
    # @return [String] JWT refresh token
    def encode_refresh_token(user)
      encode(user, 7.days.from_now)
    end
  end
end