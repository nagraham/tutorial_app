class User < ActiveRecord::Base

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_many :microposts, dependent: :destroy

  validates :name,
            presence: true,
            length: { maximum: 50 }

  validates :email,
            presence: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 6 }

  # helps to ensures uniqueness
  before_create :create_remember_token
  before_save { self.email = email.downcase } # <- callback function

  # this one method sets up all this password functionality:
  #  - password, password_confirmation attributes
  #  - require presence of a password
  #  - require the passwords match
  #  - add an authenticate method
  # It depends on the model having a "password_digest" column in the DB
  has_secure_password

  def feed
    Micropost.where('user_id = ?', id)
  end

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)    # to string to handle "nil" which sometimes happens in tests
  end

  private

    def create_remember_token
      self.remember_token = User.digest(User.new_remember_token)
    end

end
