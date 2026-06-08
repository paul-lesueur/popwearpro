class ProfilesController < ApplicationController
  def show
  end

  def update
    if profile_params[:password].present?
      if current_user.update_with_password(profile_params)
        bypass_sign_in(current_user)
        redirect_to profile_path, notice: "Profil mis à jour."
      else
        render :show, status: :unprocessable_entity
      end
    else
      if current_user.update_without_password(profile_params.except(:password, :password_confirmation, :current_password))
        redirect_to profile_path, notice: "Profil mis à jour."
      else
        render :show, status: :unprocessable_entity
      end
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
  end
end
