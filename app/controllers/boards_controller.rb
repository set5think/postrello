class BoardsController < ApplicationController

  def index
    if params[:organization]
      @boards = Board.where(:organization_id => params[:organization][:id])
    else
      @boards = Board.all
    end
  end

  def show
    @board = Board.find(params[:id])
  end
end
