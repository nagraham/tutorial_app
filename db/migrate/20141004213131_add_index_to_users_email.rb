# This migration adds an index to the 'email' column of the 'User' database
# which helps to ensure strict uniqueness of the email address. This
# compliments the uniqueness validation in the User model by addressing
# race conditions.
class AddIndexToUsersEmail < ActiveRecord::Migration
  def change
    add_index :users, :email, unique: true
  end
end
