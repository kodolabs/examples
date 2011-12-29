class Ring < ActiveRecord::Base
  acts_as_api
  include ApplicationHelper
  
  belongs_to  :call
  belongs_to  :user

  has_one     :recording
  has_one     :note

  has_many    :conversations

  delegate :name, :to => :user, :prefix => 'user'

  STATUSES = %w(new init call ended)
  DEFAULT_STATUS = "new"
  TIMEOUT = 30

  validates :call_id, :presence => true
  validates :user_id, :presence => true

  before_create :set_defaults
  before_save :set_duration

  scope :recent, order("#{self.table_name}.created_at DESC")
  scope :today, where("#{self.table_name}.created_at BETWEEN ? AND ?", Date.today.beginning_of_day, Date.today.end_of_day)
  scope :by_account, lambda{|account| joins(:call).where("calls.account_id = ?", account.id) unless account.blank? }

  accepts_nested_attributes_for :call
  accepts_nested_attributes_for :note

  api_accessible :default do |template|
    template.add :id
    template.add :status
    template.add :duration
    template.add :note
    template.add :user
    template.add :created_at
  end

  def source
    self.user.phone_number
  end

  def target
    self.call.phone.number
  end

  def destination
    self.event.phone.number unless self.event.blank? || self.event.phone.blank?
  end

  def duration
    #if a call is made from the web app, only the started_at and ended_at are recoreded
    #if a call is made from the iphone app, the duration is explicitly set
    return self.read_attribute(:duration) if self.read_attribute(:duration)
    return 0 if started_at.blank?
    return ((self.ended_at || Time.now.utc) - self.started_at).to_i
  end

  def duration_as_string
    time_to_human(duration)
  end

  def stale
    self.status == DEFAULT_STATUS && (Time.now.utc - updated_at) >= TIMEOUT
  end

  def self.average_duration(account)
    by_account(account).select("AVG(duration) AS avg").first.avg.to_i
  end

  def self.global_average_duration
    select("AVG(duration) AS avg").first.avg.to_i
  end

  def init_call(callback)
    response = handler.init_call source, callback
    unless response.nil?
      self.callid = response['sid']
      self.status = 'init'
      save
      response
    end
  end

  def init_conference_call(callback)
    response_one = handler.init_call source, callback

    unless response_one.nil?
      response_two = handler.init_call target, callback

      unless response_two.nil?
        self.conversations << Conversation.new(:call_sid => response_one['sid'])
        self.conversations << Conversation.new(:call_sid => response_two['sid'])
        self.status = 'init'
        save
      end
    end
  end

  def dial_commands(callback)
    update_attributes :status => 'call', :started_at => Time.now
    handler.dial_twiml target, callback
  end

  def conference_commands(callback)
    update_attributes :status => 'call', :started_at => Time.now
    handler.conference_twiml id, callback
  end

  def hangup(params)
    self.ended_at = Time.now
    self.status = 'ended'
    self.dial_status = params['DialCallStatus']

    unless params['RecordingUrl'].blank?
      recording           = self.build_recording
      recording.url       = params['RecordingUrl']
      recording.duration  = params['RecordingDuration'].to_i
      recording.save
    end

    save

    handler.handgup_twiml
  end

  def hangup!
    conversations.each do |conversation|
      handler.hangup conversation.call_sid
    end
  end

private

  def handler
    TwilioHandler.new
  end

  def set_defaults
    self.status = DEFAULT_STATUS if self.status.blank?
  end

  def set_duration
    self.duration = self.ended_at - self.started_at unless self.ended_at.blank? || self.started_at.blank?
  end
end
