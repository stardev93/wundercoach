class ClassroomsController < ApplicationController
  authorize_resource

  def index
    @user = current_user
    @eventsession = Eventsession.find_by(token: params[:token])
    render layout: "classroom"
  end

  def whiteboard
    @user = current_user
    @eventsession = Eventsession.find_by(token: params[:token])
    render layout: "classroom"
  end
end
