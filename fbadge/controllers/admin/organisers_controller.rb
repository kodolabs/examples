class Admin::OrganisersController < Admin::BaseController
  before_action :set_organiser, only: [:login]

  select_section :organisers

  def index
    @collection = User.joins(:organiser).ordered.page(params[:page])
  end

  def login
    if @organiser
      sign_in @organiser
      redirect_to root_path, flash: { success: 'You successfully signed in as organiser' }
    else
      redirect_to admin_organisers_path, flash: { error: "You can't login as organiser"  }
    end
  end

  private

  def set_organiser
    @organiser = User.find(params[:id])
  end
end
