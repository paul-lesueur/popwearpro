class ProfilesController < ApplicationController
  def show
  end

  def update
    if changing_sensitive_fields?
      if current_user.update_with_password(profile_params)
        sign_in(current_user, force: true)
        redirect_to profile_path, notice: "Profil mis à jour."
      else
        render :show, status: :unprocessable_entity
      end
    else
      if current_user.update_without_password(non_sensitive_profile_params)
        redirect_to profile_path, notice: "Profil mis à jour."
      else
        render :show, status: :unprocessable_entity
      end
    end
  end

  private

  def changing_sensitive_fields?
    profile_params[:password].present? ||
      (profile_params[:email].present? && profile_params[:email] != current_user.email)
  end

  def non_sensitive_profile_params
    profile_params.except(:password, :password_confirmation, :current_password)
  end

  def profile_params
    params.require(:user).permit(
      :name,
      :email,
      :avatar,
      :password,
      :password_confirmation,
      :current_password
    )
  end
end
