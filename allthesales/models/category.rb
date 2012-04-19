class Category < ActiveRecord::Base

  has_ancestry :cache_depth => true

  has_many :products, :dependent => :nullify
  has_one :featured_category, :dependent => :destroy

  include HasSlugg

  validates :name, :presence => true
  validate :validates_featured_only_top

  scope :by_name, order(:name)
  scope :featured, lambda { |limit| where(:featured => true, :ancestry => nil).limit(limit) unless limit.blank? }
  scope :with_products, where("products_count > 0")
  scope :second_level, where("ancestry_depth = 1")
  scope :by_depth, lambda{|depth| where("ancestry_depth = ?", depth) unless depth.blank? }
  scope :by_store, lambda{ |store_id| store_id.blank? ? scoped : joins(:products).where("products.store_id = ? and products.archived = ?", store_id, false) }
  scope :by_brand, lambda{ |brand_id| joins(:products).where("products.brand_id = ? and products.archived = ?", brand_id, false) unless brand_id.blank? }

  def self.with_childrens(categories)
    children = self.where("ancestry in (?)", categories.map{ |c| c.id.to_s }).by_name

    arrange_nodes categories + children
  end

  def featured_children
    children.with_products.by_name.map { |c| c if c.featured }.compact
  end

  def self.by_ancestry
    sort_by_ancestry(all)
  end

  def siblings_for_select
    siblings.by_name.map{ |c| [c.name, c.id] }.unshift(['', ''])
  end

  def childrens_for_select
    children.by_name.map{ |c| [c.name, c.id] }.unshift(['', ''])
  end

  def subcats
    children.with_products.by_name
  end

  def level
    self.ancestry_depth + 1
  end

  def to_s
    name
  end

  def parametrized_ancestors_names
    self.ancestors.collect {|a| a.name.parameterize }
  end

  def self.get_category_from_slug(category_path)
    requested_tree = category_path.split('/')
    possible_slugs = Slugg.find_all_by_name(requested_tree.pop.parameterize)

    possible_slugs.each do |slug|
      tree_in_fact = slug.sluggable.parametrized_ancestors_names
      return {:by_category => slug.sluggable_id.to_s} if requested_tree == tree_in_fact
    end

    return {}
  end

  def self.random_products category_ids
    product_ids = []
    category_ids.each do |id, qty|
      products = Product.by_category_ar(Category.find(id).descendant_ids).featured.map &:id
      qty.times do
        val = rand(products.length - 1)
        id = products[val]
        if id
          product_ids << id
          products.delete_at val
        end
      end
    end

    product_ids.uniq
  end

  def self.filter_ids_on_level(ids, level, cat_id)
    case level.to_i
      when 1
        return ids.map { |i| i[0] }.uniq
      when 2
        return ids.map { |i| i[1] if cat_id.eql?(i[0]) }.compact.uniq
      when 3
        return ids.map { |i| i[2] if cat_id.eql?(i[1]) or cat_id.eql?(i[2]) }.compact.uniq
    end
  end


  def self.recalculate_products_count
    all.each { |cat| cat.update_attribute(:products_count, 0) }
    puts "products counter nullified for all categories"
    find_all_by_ancestry_depth(2).each do |cat|
      cat.increase_counter(cat.products.where(:archived => false).count) if cat.products.where(:archived => false).count > 0
    end

    find_all_by_ancestry_depth(1).each do |cat|
      cat.increase_counter(cat.products.where(:archived => false).count) if cat.products.where(:archived => false).count > 0
    end
  end

  def decrease_counter(count=1)
    self.update_attribute(:products_count, self.products_count - count)
    self.parent.update_attribute(:products_count, self.parent.products_count - count)
    self.parent.parent.update_attribute(:products_count, self.parent.parent.products_count - count) if self.ancestry_depth.eql?(2)
  end

  def increase_counter(count=1)
    self.update_attribute(:products_count, self.products_count + count)
    self.parent.update_attribute(:products_count, self.parent.products_count + count)
    self.parent.parent.update_attribute(:products_count, self.parent.parent.products_count + count) if self.ancestry_depth.eql?(2)
  end

  def self.load_for_public(options)
    if (options[:by_category] && options[:by_store]) #slug=category/store or slug=category and params[:by_store].not_blank?
      return categories = Category.find(options[:by_category]).children.empty? ? Category.order("name ASC").siblings_of(options[:by_category]).by_store(options[:by_store]).with_products.uniq : Category.order("name ASC").descendants_of(options[:by_category]).by_store(options[:by_store]).each{|e| e.ancestors.at_depth(1)}.flatten.uniq
    elsif options[:by_category] #slug=category
      return categories = Category.find(options[:by_category]).children.empty? ? Category.order("name ASC").siblings_of(options[:by_category]).with_products : Category.order("name ASC").children_of(options[:by_category]).with_products.all
    elsif options[:by_store] && (not options[:by_store].empty?) #slug=store
      return categories = Category.by_store(options[:by_store]).with_products.map(&:root).uniq.sort{|a,b| a.name <=> b.name }
    end
    Category.order("categories.name ASC").roots.with_products.by_name
  end

  def genders
    if self.products
      gender = ((not self.products.by_male.empty?) && (not self.products.by_female.empty?) ) ? "Womens and Mens" : ((self.products.by_male.empty?) && (not self.products.by_female.empty?)) ? "Womens" : "Mens"
      return gender
    end
  end

  private

    def validates_featured_only_top
      errors.add(:featured, ' can only be set for 1st and 2nd level categories') if self.depth > 1 && self.featured
    end
end


