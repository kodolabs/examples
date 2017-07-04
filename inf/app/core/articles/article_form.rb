module Articles
  class ArticleForm < Schedule::BaseForm
    attribute :content, String
    attribute :customer_id, Integer
    attribute :image_ids_str, String
    attribute :images, Array

    validates_with Articles::Validator

    def image_ids_field_values
      return image_ids_str if image_ids_str.present?
      images.map(&:id).join(', ')
    end

    def image_data_options
      {
        max_count: Articles::Validator::MAX_IMAGE_COUNT,
        max_size: ::ArticleImage.max_size * 1_000_000,
        url: user_article_images_path
      }
    end

    def model_attributes
      attributes.except(
        :targets, :date, :time, :created_at, :customer_id,
        :image_ids_str, :images, :campaigns, :disabled
      )
    end

    def new_modal_attributes
      { customer_id: customer_id }
    end

    def publications
      return unless id
      Article.find(id).publications
    end

    def title
      persisted? ? 'Post' : 'New Post'
    end

    def delete_share_path
      user_article_path(share.id)
    end

    private

    def owned_pages
      @owned_pages ||= OwnedPageDecorator.decorate_collection(
        Customer.find(customer_id).owned_pages.includes(page: [:provider])
      )
    end
  end
end
