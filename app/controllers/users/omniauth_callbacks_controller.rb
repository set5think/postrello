class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def trello

  end
end
