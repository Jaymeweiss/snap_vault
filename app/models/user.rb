class User < ApplicationRecord
  has_secure_password
  has_many :uploaded_files, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: URI::MailTo::EMAIL_REGEXP }

  before_save { self.email = email.downcase }
end
