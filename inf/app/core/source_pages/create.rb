module SourcePages
  class Create < Rectify::Command
    def initialize(form, feed)
      @form = form
      @feed = feed
    end

    def call
      return broadcast(:invalid) if @form.invalid?
      return broadcast(:invalid_source) unless source_present?(page_form_attributes)
      transaction do
        page = find_or_create_page
        return broadcast(:invalid_page) unless page
        source_page = create_source_page(source_page_form_attributes, @feed)
        return broadcast(:invalid) unless source_page
        page.source_pages << source_page
        @source_page = source_page
      end
      broadcast(:ok, @source_page)
    end

    private

    def find_provider(provider_id)
      Provider.find_by(id: provider_id)
    end

    def source_present?(attrs)
      SourcePage::Present.new(attrs[:provider], attrs[:handle_type], attrs[:handle]).call
    end

    def find_or_create_page
      Page::FindOrCreateAndFetch.new(
        page_form_attributes[:provider],
        page_form_attributes[:handle_type],
        page_form_attributes[:handle]
      ).call
    end

    def create_source_page(form_attributes, feed)
      feed.source_pages.create(form_attributes)
    end

    def source_page_form_attributes
      @form.attributes.except(:handle, :provider, :handle_type)
    end

    def page_form_attributes
      @form.attributes.except(:title)
    end
  end
end
