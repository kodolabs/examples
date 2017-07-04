class Admin::OrganiserInvitationsController < Admin::BaseController
  select_section :organisers

  def index
    @collection = OrganiserInvitation.pending.ordered.page(params[:page])
  end

  def new
    @form = Organisers::OrganiserInvitationForm.new
  end

  def create
    @form = Organisers::OrganiserInvitationForm.from_params params

    Organisers::Invite.call(current_admin, @form) do
      on(:ok)       { redirect_to admin_organisers_path, notice: "Successfully invited \"#{@form.email}\"" }
      on(:granted)  { redirect_to admin_organisers_path, notice: "User \"#{@form.email}\" invited as organiser" }
      on(:exists)   { redirect_to admin_organisers_path, notice: "User \"#{@form.email}\" is already an organiser" }
      on(:invalid)  { render :new }
    end
  end

  def destroy
    @resource = OrganiserInvitation.find(params[:id])
    flash = if @resource.destroy
      { success: 'Organiser invitation succesfully deleted' }
    else
      { error: 'Cannot delete organiser invitation' }
    end
    redirect_to admin_organiser_invitations_path, flash: flash
  end
end
