class Facilitator::ProfilesController < Facilitator::BaseController
  before_action :set_facilitator

  def update
    if @facilitator.update(facilitator_params)
      redirect_to facilitator_profile_path, notice: 'Successfully updated your details'
    else
      flash[:error] = 'Error updating your profile'
      render :show
    end
  end

  def update_password
    if @facilitator.update(password_params)
      sign_in :facilitator, @facilitator, bypass: true
      redirect_to facilitator_profile_path, notice: 'Your password was successfully updated'
    else
      flash[:error] = 'Error updating your password'
      render :show
    end
  end

  private

  def set_facilitator
    @facilitator = current_facilitator
  end

  def facilitator_params
    params.require(:facilitator).permit(
      :first_name, :last_name, :email, :company_name, :phone,
      :address, :city, :country
    )
  end

  def password_params
    params.require(:facilitator).permit(:password, :password_confirmation)
  end
end
