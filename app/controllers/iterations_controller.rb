class IterationsController < ApplicationController

  def index
    @iterations = Iteration.all
  end

  def show
    @iteration = Iteration.find(params[:id])
  end

  def new
    @iteration = Iteration.new
  end

  def create
    @iteration ||= Iteration.new
    @iteration.update_attributes(params[:iteration])
    redirect_to settings_path
  end

  def edit
    @iteration = Iteration.find(params[:id])
  end

  def update
    @iteration ||= Iteration.find(params[:id])
    @iteration.update_attributes(params[:iteration])
    redirect_to settings_path
  end

  def destroy
    @iteration = Iteration.find(params[:id])
    @iteration.destroy
    redirect_to settings_path
  end

end
