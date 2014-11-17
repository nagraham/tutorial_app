class Micropost < ActiveRecord::Base

  # --- Associations ---
  belongs_to :user

  # --- Scope ---
  default_scope -> { order('created_at DESC') }

  # --- Validations ---
  validates :user_id, presence: true

  validates :content,
            length: { maximum: 140 },
            presence: true

  # --- Methods ---
  # NOTE: "followed_user_ids" from user is a rails syntatic sugar method that
  #   gives you result of user.followed_users.map(&:ids)
  # NOTE: By using raw SQL instead of user.followed_user_ids, we allow for
  #   better scaling--if a user follows 100,000 users, we don't have to hold
  #   all those ids in memory; instead, we move that calculation to the
  #   database, where it is more efficient.
  def self.from_users_followed_by(user)
    # followed_user_ids = user.followed_user_ids
    followed_user_ids = "SELECT followed_id FROM Relationships
                         WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
                    user_id: user.id)
  end
end
