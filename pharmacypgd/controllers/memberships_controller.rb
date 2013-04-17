class Admin::MembershipsController < Admin::BaseController
  inherit_resources
  before_filter :set_object


  def deleted
    @deleted = @object.memberships.with_pharmacist_role.deleted
  end

  def manage
    @object.memberships.by_ids(params[:membership_id]).each do |m|
      m.send params[:commit].downcase
    end

    if @object.is_a?(Organisation)
      redirect_to (params[:commit].downcase == 'reinstate') ? deleted_admin_organisation_memberships_path(@object) : admin_organisation_memberships_path(@object)
    elsif @object.is_a?(User)
      redirect_to admin_user_path(@object)
    end
  end

  def collection
    @memberships ||= @object.memberships.with_pharmacist_role.undeleted
  end

  def set_object
    @object ||= Organisation.find(params[:organisation_id]) unless params[:organisation_id].blank?
    @object ||= User.find(params[:user_id]) unless params[:user_id].blank?
    @organisation = @object if @object.is_a?(Organisation)
    @user = @object if @object.is_a?(User)

    @pgds = Pgd.all
  end
end