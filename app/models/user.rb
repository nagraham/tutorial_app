class User < ActiveRecord::Base

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name,  presence: true,
                    length: { maximum: 50 }

  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 6 }

  # helps to ensures uniqueness
  before_save { self.email = email.downcase } # <- callback function

  # this one method sets up all this password functionality:
  #  - password, password_confirmation attributes
  #  - require presence of a password
  #  - require the passwords match
  #  - add an authenticate method
  # It depends on the model having a "password_digest" column in the DB
  has_secure_password
end
