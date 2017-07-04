class Organiser::RegistrationsController < ApplicationController
  before_action :check_user

  def new
    @form = UserRegistrationForm.new token: params[:token]
  end

  def create
    @form = UserRegistrationForm.from_params params

    Organisers::Register.call(@form) do
      on(:ok) do |user|
        sign_in user
        redirect_to root_path, notice: 'You have successfully signed up.'
      end

      on(:invalid) { render :new }
      on(:error) { render :new }
    end
  end

  private

  def check_user
    redirect_to root_path if user_signed_in?
  end
end
