class Profile::TagsController < ApplicationController
  def create
    @tag_form = Tags::TagForm.from_params(params)
    Tags::Create.call(@tag_form) do
      on(:ok) { |tag| render json: { id: tag.id } }
      on(:invalid) do |form|
        render status: :bad_request, json: { errors: form.errors.full_messages }
      end
    end
  end
end
