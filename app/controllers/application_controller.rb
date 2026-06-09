class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # Application 100 % francophone : on force la locale FR (dates, libellés).
  before_action { I18n.locale = :fr }

  # Exposé aux vues (sidebar : badge compteur de commandes).
  helper_method :current_establishment

  private

  def current_establishment
    current_user.establishment
  end
end
