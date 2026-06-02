class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  private

  def current_establishment
    current_user.establishment
  end
end
