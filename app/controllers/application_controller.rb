class ApplicationController < ActionController::Base
  before_action :redirect_naked_domain_to_www
  before_action :authenticate_user!

  # Exposé aux vues (sidebar : badge compteur de commandes).
  helper_method :current_establishment

  private

  def redirect_naked_domain_to_www
    return unless Rails.env.production?
    return unless request.host == "popwear-pro.fr"

    redirect_to "https://www.popwear-pro.fr#{request.fullpath}",
                status: :moved_permanently,
                allow_other_host: true
  end

  def current_establishment
    current_user.establishment
  end
end
