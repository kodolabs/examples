module Tags
  class Create < Rectify::Command
    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid, @form) if @form.invalid?
      tag = Tag.new(@form.model_attributes)
      return broadcast(:invalid, @form) unless tag.save
      broadcast(:ok, tag)
    end
  end
end
