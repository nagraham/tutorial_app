class User < ActiveRecord::Base

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  #
  # --- Relationships ---
  #
  has_many :microposts, dependent: :destroy

  # We are explicitly telling rails to associate this user's (self's) id
  # with "follower_id" as the foreign key
  has_many :relationships, foreign_key: 'follower_id', dependent: :destroy

  # These are the users this user (self) is following.
  # Source allows us to override the default (which would require us to write
  # "has many followeds" for Rails to get followed_ids )
  has_many :followed_users, through: :relationships, source: :followed

  # We "flip" the relationships table by associating with a different foreign key
  # Also, we create a second model with the "class_name"
  has_many :reverse_relationships, class_name: 'Relationship',
                                   foreign_key: 'followed_id',
                                   dependent: :destroy

  # You don't need "source" in this instance (followers would get translated to
  # follower_id correctly . . . leave on for parallelism w/ :followed_users)
  has_many :followers, through: :reverse_relationships, source: :follower

  #
  # --- Validations ---
  #
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
    # Micropost.where('user_id = ?', id)
    Micropost.from_users_followed_by(self)
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
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
