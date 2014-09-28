class StaticPagesController < ApplicationController

  # Hitting /static_pages/home calls home;
  # and because it inherits from ApplicationController,
  # which calls this method and then renders the view,
  # an empty controller method means only the view is displayed.
  def home
  end

  def help
  end
  
  def about
  end
end
