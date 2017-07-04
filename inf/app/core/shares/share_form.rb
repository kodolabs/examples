module Shares
  class ShareForm < Schedule::BaseForm
    attribute :customer
    attribute :shareable
    attribute :message
    attribute :auto, Boolean

    validates_with Shares::Validator

    def map_model(model)
      self.share = model
    end

    def date
      super.presence || (model&.scheduled_at || model&.created_at).try(:strftime, '%d/%m/%Y')
    end

    def time
      super.presence || (model&.scheduled_at || model&.created_at).try(:strftime, '%I:%M %p')
    end

    def auto
      false
    end

    def url
      persisted? ? user_share_path(url_params.merge(id: id)) : user_shares_path(url_params)
    end

    def share_button_text
      scheduled_at.presence ? 'Schedule Share' : 'Share Now'
    end

    def model_attributes
      attributes.except(
        :targets, :date, :time, :shareable, :customer, :created_at, :campaigns,
        :model, :share, :disabled
      )
    end

    def new_modal_attributes
      { shareable: shareable, customer: customer }
    end

    def shareable_type
      shareable.class.name
    end

    def form_class
      "share-#{shareable_type.downcase}"
    end

    def publications
      return unless id
      Share.find(id).publications
    end

    def title
      'Share'
    end

    def delete_share_path
      user_share_path(url_params.merge(id: share.id))
    end

    private

    def owned_pages
      @owned_pages ||= owned_pages_with_scope
    end

    def owned_pages_with_scope
      customer.owned_pages.includes(:page)
    end

    def provider
      shareable.page.provider.name
    end

    def url_params
      { shareable_id: shareable.id, shareable_type: shareable_type.pluralize.downcase }
    end
  end
end
