# This migrations adds a password digest column to the users table. This
# is necessary for the password authorization to work.
#
# This was automatically created with:
#   rails generate migration add_password_digest_to_users password_digest:string
class AddPasswordDigestToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_digest, :string
  end
end
