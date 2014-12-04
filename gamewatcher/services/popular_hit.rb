module PopularHit
  extend ActiveSupport::Concern

  PopularModels = ['article', 'news'] if !defined?(PopularModels)

  included do
    has_one :popular, as: :popularable, dependent: :destroy
    scope   :popular, -> { joins(:popular).merge(Popular.sorted) }
    after_create :clean_stats_hash

    private
    def clean_stats_hash
      Stats::Popular.send(:clean_up_hashes)
    end
  end

  def hit
    Populars::HitWorker.perform_async(self.class.name.classify.constantize.base_class.name.underscore.to_sym, self.id)
  end
end
