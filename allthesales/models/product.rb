class Product < ActiveRecord::Base

  ORDER_OPTIONS = {
    'Price (from low to high)'       => 'price asc',
    'Price (from high to low)'       => 'price desc',
    'Discount % (from low to high)'  => 'discount asc',
    'Discount % (from high to low)'  => 'discount desc',
    'new_tag_timestamp desc'         => 'new_tag_timestamp desc'
  }

  DEFAULT_ORDER = 'new_tag_timestamp desc'

  DEFAULT_PER_PAGE = 12

  PER_PAGE_OPTIONS = {
    '12'    => 12,
    '24'    => 24,
    '48'    => 48,
    '96'    => 96,
    "All"    => 999
  }

  mount_uploader :image, ProductImageUploader

  belongs_to :store, :counter_cache => true
  belongs_to :brand, :counter_cache => true
  belongs_to :category

  has_one :day_product

  slug :title_for_slug

  validates :name,        :presence => true
  validates :brand_id,    :presence => true
  validates :store_id,    :presence => true
  validates :category_id, :presence => true
  validates :male,        :presence => { :if => lambda {|p| p.female.blank? } }
  validates :female,      :presence => { :if => lambda {|p| p.male.blank? } }
  validates :price,       :presence => true
  validates :value,       :presence => true
  validates :discount,    :presence => true
  validate  :without_children
  validate  :price_greater_than_value

  before_validation do
    self.discount = 100 - self.price / self.value * 100 unless self.price.blank? or self.value.blank?
  end

  def without_children
    return if category.blank?
    errors.add(:category_id, 'This category have subcategories, please select one of them!') if category.ancestry_depth.eql?(1) && category.children.any?
  end

  def price_greater_than_value
    if self.price.present? and self.value.present?
      if self.price > self.value
        errors.add(:price, 'should not be greater than value')
      end
    end
  end

  def title_for_slug
      "#{Brand.find(brand_id).slugg.name}-#{name.parameterize}" if brand_id
  end

  #scope :by_name, lambda { |by_name| order("name #{by_name}") unless by_name.blank? }
  #scope :by_store_name, lambda { |by_store| joins(:store).order("stores.name #{by_store}") unless by_store.blank? }

  define_index do
    indexes :name, :sortable => true
    indexes :description
    indexes store(:name), :as => :store_name, :sortable => true
    indexes brand(:name)
    indexes category(:name)
    has :store_id, :brand_id, :category_id, :male, :female, :price, :discount, :featured, :created_at, :new_tag_timestamp, :updated_at, :archived

    set_property :delta => :delayed
  end

  sphinx_scope :by_brand do |brand_id|
    { :with => {:brand_id => brand_id} }
  end

  sphinx_scope :by_store do |store_id|
    { :with => {:store_id => store_id} }
  end

  sphinx_scope :by_category do |category_id|
    { :with => {:category_id => Category.find(category_id).presence.subtree_ids } }
  end

  sphinx_scope :by_price do |min, max|
    { :with => {:price => min.to_f..max.to_f } }
  end

  sphinx_scope :by_discount do |min, max|
    { :with => {:discount => min.to_i..max.to_i } }
  end

  sphinx_scope :by_male do
    { :with => {:male => true } }
  end

  sphinx_scope :by_female do
    { :with => {:female => true } }
  end

  sphinx_scope :by_name do |order|
    { :order => "name #{order}"}
  end

  sphinx_scope :by_store_name do |order|
    { :order => "store_name #{order}"}
  end

  sphinx_scope :ordered do |order|
    { :order => self::ORDER_OPTIONS.value?(order) ? order : self::DEFAULT_ORDER }
  end

  #sphinx_scope :featured do
  #  { :with => {:featured => true }, :limit => 9 }
  #end

  #sphinx_scope :by_keyword do |keyword|
  #  { :conditions => {:name => keyword } }
  #end

  scope :homepage, where(:homepage => true).includes(:brand, :store)
  scope :featured, where(:featured => true)
  scope :by_category_ar, lambda {|category_ids| where("category_id in (?)",category_ids) }
  scope :not_the_same, lambda{|id| where("id <> ? and archived = false", id) unless id.blank? }
  scope :by_gender, lambda{ |male, female|
    r = where('1')
    r = r.where(:male => true) if male
    r = r.where(:female => true) if female
    r
  }

  def self.set_homepage(product_ids)
    Product.unset_all_homepage
    product_ids.each do |id|
      Product.find(id).update_attribute(:homepage, true)
    end
  end

  def self.unset_all_homepage
    Product.homepage.each do |product|
      product.update_attribute(:homepage, false)
    end
  end

  def related_products by_male = nil, by_female = nil
    if(by_male && by_female) || (!by_male && !by_female)
      if male != female
        return Product.not_the_same(id).by_category_ar(category_id).by_gender(male, female).limit(6)
      else
        return Product.not_the_same(id).by_category_ar(category_id).limit(6)
      end
    else
      final_male    = male && by_male
      final_female  = female && by_female
      if final_male != final_female
        return Product.not_the_same(id).by_category_ar(category_id).by_gender(final_male, final_female).limit(6)
      else
        return Product.not_the_same(id).by_category_ar(category_id).limit(6)
      end
    end
  end

  def product_stat
    ProductStat.by_product id
  end

  def new?
    new_tag_timestamp.nil? ? false : (new_tag_timestamp + 2.days).future?
  end

  def sold?
    archived
  end

  def categories
    return [] if category.blank?
    category.path.collect{|e| e.name }
  end

  def brand_name
    brand.name unless brand.blank?
  end

  def store_name
    store.name unless store.blank?
  end

  def genders
    result = []
    ['male', 'female'].each { |g| result << g if attributes[g] }
    result
  end

  def self.max_price
    round_to = 100
    result = maximum :price
    return 100 if result.nil? or result == 0 or result == 100
    (result / round_to).to_i * round_to + round_to if result % round_to > 0
  end

  def self.total_average_price
    all.sum(&:price) / count rescue nil
  end

  def self.total_average_discount
    all.sum(&:discount) / count rescue nil
  end

  # ----------------------------------------------------------------------------
  #  statistics tracking methods

  def self.track_search(products)
    Product.set_snapshot_date
    $redis.multi do
      products.each do |product|
        $redis.hincrby product.redis_key, 'search', 1 unless product.nil?
      end
    end
  end

  def track_impression
    Product.set_snapshot_date
    $redis.hincrby redis_key, 'impression', 1
  end

  def track_click
    Product.set_snapshot_date
    $redis.hincrby redis_key, 'click', 1
  end

  def impressions
    $redis.hget(redis_key, 'impression').to_i
  end

  def clicks
    $redis.hget(redis_key, 'click').to_i
  end

  def searches
    $redis.hget(redis_key, 'search').to_i
  end

  def reset_stats
    $redis.multi do
      ['impression', 'click', 'search'].each do |field|
        $redis.hdel redis_key, field
      end
    end
  end

  def self.get_stats_snapshot
    time_from = Time.at $redis.get('products_snapshot_date').to_i
    time_to   = Time.now

    puts " -- date range: #{time_from} - #{time_to}"

    self.all.each do |product|

      stats = $redis.hgetall product.redis_key

      #puts " -- stats #{stats.inspect}"

      ProductStat.create  :product_id => product.id,
                          :store_id   => product.store.id,
                          :time_from  => time_from,
                          :time_to    => time_to,
                          :searches   => stats["search"].to_i,
                          :impressions=> stats["impression"].to_i,
                          :clicks     => stats["click"].to_i

      product.reset_stats
    end

    # update snapshot time
    $redis.set 'products_snapshot_date', time_to.to_i
  end

  def self.set_snapshot_date
    $redis.setnx 'products_snapshot_date', Time.now.utc.to_i
  end

  def redis_key
    "product_#{id}"
  end
end
