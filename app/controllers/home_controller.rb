class HomeController < ApplicationController

  def index
    @organizations = Organization.all
  end

end
