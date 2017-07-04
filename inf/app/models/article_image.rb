class ArticleImage < ApplicationRecord
  mount_uploader :file, ArticleImageUploader
  belongs_to :article

  def self.max_size
    Setting['share.max_file_size'].to_i.try(:megabytes)
  end

  def self.min_width
    Setting['share.min_file_width'].to_i
  end

  def self.min_height
    Setting['share.min_file_height'].to_i
  end

  scope :not_used, -> { where(article: nil) }
  scope :older_than_day, -> { where('created_at < ?', 1.day.ago) }

  validates :file, file_size: { less_than: ->(record) { record.class.send(:max_size) } },
                   file_geometry: {
                     minimum: lambda do
                                [min_width, min_height]
                              end
                   }

  delegate :url, to: :file

  def banner?
    !banner_data.nil?
  end
end
