class MicropostsController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy]
  before_action :correct_user, only: [:destroy]

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = 'Micropost created!'
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  # micropost is defined for destroy in the before filter
  def destroy
    @micropost.destroy
    flash[:error] = 'Micropost deleted!'
    redirect_to root_url
  end

  private

  # define strong parameters for creating new microposts
  def micropost_params
    params.require(:micropost).permit(:content)
  end

  #
  # --- Filters ---
  #

  # Checks whether the current user actually has the micropost to delete.
  # NOTE: find_by returns nil if the micropost is not found;
  #  find() raises an exception; you could also use a rescue block
  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url if @micropost.nil?
  end

end