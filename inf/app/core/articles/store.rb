module Articles
  class Store < Rectify::Command
    include ::Schedule::Base

    def initialize(form, customer)
      @form = form
      @customer = customer
    end

    def call
      if @form.invalid?
        set_images
        return broadcast(:invalid)
      end

      init
      process_pages
      return broadcast(:disconnected_account) if disconnected_account?
      process_date
      save
      process_worker
      broadcast(@share.scheduled_at ? :scheduled : :posted)
    end

    private

    def init
      @record = find_or_build
      @record.assign_attributes(@form.model_attributes.except(:scheduled_at, :model, :share))
      @record.image_ids = ArticleImage.where(id: image_ids_arr).pluck(:id)
      @share = if @record.new_record?
        @record.shares.build(customer: @customer)
      else
        @record.shares.find_by(customer: @customer)
      end
      @share.assign_attributes(@form.model_attributes.slice(:scheduled_at))
    end

    def image_ids_arr
      return [] if @form['image_ids_str'].blank?
      @form['image_ids_str'].split(',').reject(&:blank?).map(&:to_i)
    end

    def set_images
      records = ArticleImage.where(id: image_ids_arr)
      @form.images = image_ids_arr.map do |id|
        records.find { |r| r.id == id }
      end
    end
  end
end
