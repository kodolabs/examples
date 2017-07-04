module Shares
  class Store < Rectify::Command
    include ::Schedule::Base

    def initialize(form, post, customer)
      @form = form
      @post = post
      @customer = customer
    end

    def call
      return broadcast(:invalid) if @form.invalid?
      init
      process_pages
      return broadcast(:disconnected_account) if disconnected_account?
      process_date
      save
      share_news
      process_worker
      action = @record.scheduled_at ? :scheduled : :shared
      broadcast(action, @record)
    end

    private

    def init
      @record = find_or_build
      @record.assign_attributes(@form.model_attributes)
      @share = @record
    end

    def share_news
      return unless @share.shareable.is_a? News
      @form = ResolvedItems::DecisionForm.from_params(
        customer: @customer, decideable: @share.shareable
      )
      ResolvedItems::Decide.new(@form, :shared).call
    end
  end
end
