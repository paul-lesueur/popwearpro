class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # Exposé aux vues (sidebar : badge compteur de commandes).
  helper_method :current_establishment

  private

  def current_establishment
    current_user.establishment
  end
end
