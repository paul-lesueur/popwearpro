module ApplicationHelper
  # Initiales pour l'avatar du header (max 2 lettres), à partir du nom sinon de l'email.
  def user_initials(user)
    source = user.name.presence || user.email
    source.split(/[\s@.]+/).reject(&:blank?).first(2).map { |word| word[0] }.join.upcase
  end
end
