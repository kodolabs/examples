class RingsController < ApplicationController
  before_filter :require_user
  select_section :calls, :only => [:index]

  def index
    respond_to do |format|
      format.html do
        page ||= params[:page]
        @rings = current_account.rings.paginate(:page => page, :per_page => 20, :order => "created_at DESC")
      end

      format.js do
        call = current_account.calls.find(params[:call_id])
        render :partial => 'previous', :locals => { :rings => call.rings }
      end

      format.json do
        call = current_account.calls.find(params[:call_id])
        render_for_api :default, :json => call.rings.order("created_at desc"), :root => :rings
      end  
    end
  end

  def edit
    @ring = current_user.rings.find(params[:id])

    respond_to do |f|
      f.html
      f.js { render :layout => false }
    end
  end

  def update
    @ring = current_user.rings.find(params[:id])

    # do something if @ring.blank?
    respond_to do |f|

      f.json {
        if @ring.update_attributes(params[:ring])
          render :json => { :success => true }
        else
          render :json => { :success => false }
        end
      }
    end
  end

  def create
    @call = Call.find(params[:call_id] || params[:ring][:call_id])
    attributes = {:user_id => current_user.id}
    #extra params (i.e status) may be provided by the Iphone app
    if params[:ring]
      attributes = params[:ring].merge(attributes)
    end
    @ring = @call.rings.build(attributes)
    if @ring.save
      begin
        if @ring.status == "new"
          @ring.init_conference_call conference_callbacks_url(:host => AppConfig['callbacks_host']) 
        end
      rescue Exception
        puts "Got an exception"
        @error = $!.to_s
        respond_to do |format|
          format.json { render :json => {:error => @error} and return }
        end
      end

      respond_to do |format|
        format.json { render :json => @error ? @error : @ring.to_json(:methods => [:duration_as_string]) }
      end
    else
      respond_to do |format|
        format.json { render :json => {:error => 'Can not save object'} }
      end
    end
  end

  def status
    @ring = Ring.find(params[:id])

    @ring.hangup! if @ring.stale

#    logger.error @ring.inspect

    respond_to do |format|
      format.json { render :json => @ring.to_json(:methods => [:duration_as_string]) }
    end
  end

  def hangup
    @ring = Ring.find(params[:id])

    @ring.hangup!

    respond_to do |format|
      format.json { render :json => @ring.to_json(:methods => [:duration_as_string]) }
    end
  end

  private

#    def load_additional_entities
#      @ring_statuses = Ring::STATUSES
#      @event_statuses = Event::STATUSES
#    end
end
