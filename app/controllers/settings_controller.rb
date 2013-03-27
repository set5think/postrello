class SettingsController < ApplicationController

  def index
    @iterations = Iteration.all
    @boards = Board.all
  end

end
