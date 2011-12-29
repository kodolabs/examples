class CallsController < ApplicationController

  inherit_resources

  select_section :calls

  include ApplicationHelper

  before_filter :require_user
  before_filter :load_dependencies
  before_filter :history, :only => [:show]
  before_filter :load_customer_phone_numbers, :only => [:new, :create, :edit]
  before_filter :load_event_scripts, :only => [:new, :create, :edit]

  has_scope :active, :type => :boolean, :only => [:index, :active]
  has_scope :scheduled, :type=>:boolean, :only => [:index]
  has_scope :archived, :type => :boolean, :only => [:archived]
  has_scope :by_event
  has_scope :by_user
  has_scope :by_customer

  has_scope :unassigned_or_belongs_to

  def index
    params['active'] = true
  end

  def create
    create! {collection_url}
  end

  def update
    update! do |success, failure|
      success.html { redirect_to collection_url }
      success.json { render_for_api :default, :json => resource, :root => :call }
      failure.json { render :json => {:error => @error} }
    end
  end

  def archived
    params['archived'] = true
  end

  def archive
    respond_to do |format|
      format.js do
        if resource.done?
          resource.requeue!
        else
          resource.finish!
        end
      end
    end
  end

  def reschedule
    scheduled_date = Time.now

    if params[:scheduled_at]
      scheduled_date = params[:scheduled_at].to_time
    elsif params[:by]
      scheduled_date = scheduled_date.advance :hours => params[:by].to_i
    end

    resource.scheduled_at = scheduled_date
    resource.reschedule

    respond_to do |format|
      format.js
    end
  end

  def do_not_call
    resource.do_not_call

    respond_to do |format|
      format.js
    end
  end

  def random
    @call = Call.generate(current_account)
    if @call.save
      flash[:notice] = 'Call was successfully generated'
      redirect_to calls_url
    else
      flash[:error] = 'Call generation error: ' + @call.errors.full_messages.join(", ")
      redirect_to :back
    end
  end

  def assign
    @call = Call.assign_pending_call current_user
    if @call
      flash[:notice] = 'Call was assigned'
      redirect_to resource_url(@call)
    else
      flash[:notice] = 'No pending calls'
      redirect_to :back
    end
  end

  def active
    params['active'] = true
    params['unassigned_or_belongs_to'] = current_user.id
    active_calls = end_of_association_chain
    render_for_api :default, :json => active_calls, :root => :calls
  end

  def claim
    #todo: handle concurrency with pessimistic locking
    return render_for_api :default, :json => resource, :root => :call if resource.user == current_user
    return render :json=>{:error => "This call has been assigned to #{resource.user.name}."}, :status => :locked if resource.user_assigned?
    resource.assign_user(current_user)
    render_for_api :default, :json => resource, :root => :call
  end

protected

  def history
    @calls_history = Call.history(resource)
  end

  def collection
    @calls ||= end_of_association_chain.paginate(:page => params[:page], :per_page => 20 )
  end

  def begin_of_association_chain
    current_account
  end

  def load_customer_phone_numbers
    if params[:call] && params[:call][:customer_id] && customer = current_account.customers.find_by_id(params[:call][:customer_id])
      @phone_numbers = customer.phones.collect{|e|[ format_phone_number(e.number), e.id]}
    else
      @phone_numbers = []
    end
  end

  def load_event_scripts
    if params[:call] && params[:call][:event_id] && event = current_account.events.find_by_id(params[:call][:event_id])
      @scripts = event.scripts.collect{|e|[e.scenario, e.id]}
    else
      @scripts = []
    end
  end

  def load_dependencies
    @events     = current_account.events
    @categories = current_account.categories
    @customers  = current_account.customers
    @users      = current_account.users
  end
end
