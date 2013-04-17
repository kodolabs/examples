require 'spec_helper'

describe Admin::MembershipsController do

  render_views

  let(:organisation) { Factory(:organisation) }
  let(:pgd) { Factory :pgd }

  before do
    sign_in Factory(:admin)
    pgd
  end

  describe "index" do
    before do
      @pharmacist = pharmacist_with(organisation)
      @administrator = administrator_with(organisation)

      get :index, :organisation_id => organisation.id
    end

    it { should assign_to :memberships }
    it { should assign_to :organisation }

    it "should return only undeleted pharmacists" do
      assigns(:memberships).map(&:user).should include(@pharmacist)
      assigns(:memberships).map(&:user).should_not include(@administrator)
#      assigns(:memberships).should_not include(@deleted_pharmacist)
    end
  end
end
