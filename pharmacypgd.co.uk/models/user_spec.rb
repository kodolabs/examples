require 'spec_helper'

describe User do

  before do
    @user = Factory :user
  end

  it {should have_one :address}
  it {should have_many :memberships}
  it {should have_many :organisations}
  it {should have_many :assessments}
  it {should have_many :purchases}

  it {should validate_presence_of :name}
  it {should validate_presence_of :gpc_number}
#  it {should validate_uniqueness_of :gpc_number}
  it {should validate_presence_of :email}
  it {should validate_uniqueness_of :email}
  it {should validate_acceptance_of :terms}

  it "should require current password on update" do
    @user.current_password = "wrong"
    @user.should_not be_valid
    @user.errors[:current_password].should_not be_empty
    @user.current_password = @user.password
    @user.should be_valid
  end

  it {should accept_nested_attributes_for :address}

  it "should accept invitation" do
    @organisation = Factory :organisation
    @user = Factory.build :user
    @user.invite = @organisation.invite_key
    @user.save!

    #@user.reload

    @user.should be_pharmacist_of(@organisation)
  end

  it "should allow to save without password changes" do
    @user.password = nil
    @user.password_confirmation = nil
    @user.save
    @user.should be_valid
  end

  describe ".superintendent_of" do

    subject { @user.superintendent_of }

    it "should be nil if user is not an superintendent of any organisation" do
      should be_nil
    end

    it "should return organisation which user is superintendent of" do
      organisation = Factory :organisation, :superintendent => @user
      #@user.reload
      should == organisation
    end

    it "should be nil if organisation has superintendent_id but proper membership is not exists" do
      Factory :organisation, :superintendent => @user
      @user.memberships.delete_all
      should be_nil
    end

    it "should be nil if user not an administrator" do
      organisation = Factory :organisation
      @user.become_associated_with(organisation)
      should be_nil
    end

  end

  describe ".pharmacist?" do
    before do
      @organisation = Factory :organisation
    end

    subject { @user.pharmacist? }

    it "should be true if user has no memberships" do
      @user.memberships.delete_all
      should be_true
    end

    it "should be true if user has at least one membership with pharmacist role" do
      @user.become_associated_with(@organisation) # become a pharmacist with organisation
      should be_true
    end

     it "should be false if user has memberships none of which with pharmacist role" do
      membership = @user.memberships.create :organisation => Factory(:organisation)
      membership.is_administrator
      should be_false
    end

  end

  describe ".superintendent?" do

    subject { @user.superintendent? }

    it "should be false if user has no memberships" do
      @user.memberships.delete_all
      should be_false
    end

    it "should be true if user has membership with superintendent role in organisation with superintendent id == user.id" do
      Factory :organisation, :superintendent => @user
      #@user.reload
      should be_true
    end

  end

  describe "should have :pharmacists scope" do
    before do
      @pharmacist = pharmacist_factory
      @superintendent = superintendent_factory
      @admin = admin_factory
      @user = Factory :user
    end

    it "should return pharmacists only" do
      users = User.pharmacists

      users.should include(@pharmacist)
      users.should include(@superintendent)
      users.should_not include(@admin)
      users.should_not include(@user)
    end
  end

  describe "payment by PGD" do
    before do
      @organisation = Factory :organisation

      @user.become_associated_with(@organisation)
      @pgd = Factory :pgd

      @payment_1 = Factory :payment, :user => @user, :pgd => @pgd, :organisation => @organisation, :valid_until => (Date.today - 1.month)
      @payment_2 = Factory :payment, :user => @user, :pgd => @pgd, :organisation => @organisation, :valid_until => (Date.today + 12.months)

    end

    it "should return latest payment for PGD" do
      @user.payment_by_pgd_and_organisation(@pgd, @organisation).should == @payment_2
    end

    it "should return nil when no valid payment for PGD exist" do
      @pgd_2 = Factory :pgd
      @user.payment_by_pgd_and_organisation(@pgd_2, @organisation).should == nil
    end

    it "should return nil when no valid payment for organisation exist" do
      @organisation_2 = Factory :organisation
      @user.payment_by_pgd_and_organisation(@pgd, @organisation_2).should == nil
    end
  end

  describe "first/last name" do
    context "simple name" do
      before { @user = Factory :user, :name => 'Jack Sparrow' }
      specify { @user.first_name.should == 'Jack'}
      specify { @user.last_name.should == 'Sparrow'}
    end

    context "complex name" do
      before { @user = Factory :user, :name => 'Robin Wright Penn' }
      specify { @user.first_name.should == 'Robin Wright'}
      specify { @user.last_name.should == 'Penn'}
    end

    context "invalid name" do
      before { @user = Factory :user, :name => 'Batman' }
      specify { @user.first_name.should == '[your name]'}
      specify { @user.last_name.should == 'Batman'}
    end
  end
end
