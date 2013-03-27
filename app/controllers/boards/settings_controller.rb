class Boards::SettingsController < ApplicationController

  def show
    @board = Board.find(params[:board_id])
  end

  def new
    @board = Board.find(params[:board_id])
    @board_setting = BoardSetting.new
  end

  def create
    @board = Board.find(params[:board_id])
    @board_setting ||= BoardSetting.new
    @board_setting.board = @board
    @board_setting.settings.merge!({
      :done_queue => params[:board_setting][:done_queue],
      :working_queue => params[:board_setting][:working_queue],
      :backlog_queue => params[:board_setting][:backlog_queue]
    })
    if @board_setting.save
      redirect_to settings_path
    else
      flash[:alert] = @board_setting.errors.full_messages
      redirect_to new_board_setting_path(@board)
    end
  end

  def edit
    @board = Board.find(params[:board_id])
    @board_setting = BoardSetting.find(params[:id])
  end

  def update
    @board = Board.find(params[:board_id])
    @board_setting ||= BoardSetting.find(params[:id])
    @board_setting.configurations.merge!({
      :done_queue => params[:board_setting][:done_queue],
      :working_queue => params[:board_setting][:working_queue],
      :backlog_queue => params[:board_setting][:backlog_queue]
    })
    if @board_setting.save
      redirect_to settings_path
    else
      flash[:alert] = @board_setting.errors.full_messages
      redirect_to edit_board_setting_path(@board, @board_setting)
    end
  end

end
