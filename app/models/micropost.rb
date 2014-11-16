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
end
