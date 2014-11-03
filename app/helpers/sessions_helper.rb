module SessionsHelper

  def sign_in(user)
    remember_token = User.new_remember_token              # create a new token
    cookies.permanent[:remember_token] = remember_token   # place the raw token in the browser's cookies
    user.update_attribute(:remember_token,                # save the hashed token to the database; update
                          User.digest(remember_token))    #   attribute necessary to bypasses model validations
    self.current_user = user                              # set current user equal to the given user
  end

  def sign_out
    # give user new remember token for security
    current_user.update_attribute(:remember_token,
                                  User.digest(User.new_remember_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  # set the user
  def current_user=(user)
    @current_user = user
  end

  # get the user . . . because HTTP is stateless, we get the
  # remember token from cookies, hash it using the User's digest function,
  # and then use it to get the user from the DB
  def current_user
    remember_token = User.digest(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def signed_in?
    !current_user.nil?
  end

end
