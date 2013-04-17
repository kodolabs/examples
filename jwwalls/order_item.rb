class OrderItem < ActiveRecord::Base

  belongs_to :order
  belongs_to :orderable, polymorphic: true

  validates :price, :quantity, numericality: true, presence: true
  validates :orderable_id, :orderable_type, presence: true

  #serialize :details

  delegate :image, :product_name, :artist_name, :material_name, :details, :hq_cost, :wf_cost, :packing, to: :orderable
  delegate :wall_width, :wall_height, to: :orderable

  after_create :create_adjustment
  after_destroy :create_adjustment
  after_save :generate_wall_code

  before_save :set_costs

  scope :design, where(orderable_type: 'DesignOrder')
  scope :accessory, where(orderable_type: 'Accessory')
  scope :manual, where(orderable_type: 'ManualItem')

  scope :by_artist, lambda{ |artist_id|
    return if artist_id.blank?

    joins("LEFT JOIN design_orders on design_orders.id = order_items.orderable_id").
    joins("LEFT JOIN products on design_orders.designable_id = products.id").
    where("products.artist_id = ?", artist_id)
  }

  scope :by_collection, lambda{ |collection_id|
    return if collection_id.blank?

    joins("LEFT JOIN design_orders on design_orders.id = order_items.orderable_id").
    joins("LEFT JOIN products on design_orders.designable_id = products.id").
    where("products.collection_id = ?", collection_id)

  }

  # We know that if order_item.orderable_type is 'Project', then order_item is a Testprint
  # but this code smells bad and should be refactored after going live
  scope :testprint, where(orderable_type: 'Project')

  def self.build_from(cart_item)
    if cart_item.purchaseable.instance_of? Design
      orderable = DesignOrder.create_from cart_item.purchaseable
    else
      orderable = cart_item.purchaseable
    end

    order_item = OrderItem.new
    order_item.quantity   = cart_item.quantity
    order_item.price      = (cart_item.price_without_vat).round(2)
    order_item.orderable  = orderable
    order_item
  end

  def create_adjustment
    return if order.blank? || !order.paid? #dont create adjustment if this is order creation
    previous_total = order.total
    order.save!
    Adjustment.change_amount((order.total - previous_total), order.id)
  end

  def designable_type?(type)
    return false if orderable.designable.nil?
    orderable.designable.is_a?(type)
  end

  def delivery
    return 0 if order.blank?
    order.free_delivery? ? 0 : read_attribute(:delivery)
  end

  def delivery_cost(region = nil)
    params = {}
    params[:region] = region
    params[:region] ||= order.delivery_region unless order.blank?
    params[:quantity] = quantity
    orderable.delivery_cost(params)
  end

  # This is only needed to display to customer - should not be used in calculations
  def cost_with_vat
    (cost.to_f + vat.to_f).round(2)
  end

  # Used in admin panel only, when order exists, do
  def subtotal
    cost.to_f + delivery.to_f
  end

  def total_vat
    (subtotal * PriceCalculator.vat_rate).round(2)
  end

  def total_cost
    (subtotal * (1 + PriceCalculator.vat_rate)).round(2)
  end

  def product_id
    return nil if orderable_type != 'DesignOrder'
    orderable.designable.id
  end

  def filter_design_details(array)
    array.inject({}){ |hash, item| hash[item] = details[item]; hash }
  end

  def cost
    read_attribute(:cost) || calc_cost
  end

  def vat
    read_attribute(:vat) || calc_vat
  end

  protected

  def calc_cost
    (price.to_f * quantity.to_i).round(2)
  end

  def calc_vat
    (cost * PriceCalculator.vat_rate).round(2)
  end

  def set_costs
    self.cost     = calc_cost
    self.vat      = calc_vat
    self.delivery = delivery_cost unless order.blank?
  end

  def generate_wall_code
    return if order.nil?

    tmp_code = []
    tmp_code << order.id
    tmp_code << details['Collection'].parameterize if details['Collection'].present?
    tmp_code << product_name.parameterize
    tmp_code << details['Code'] if details['Code'].present? && details['Code'] != 'None'

    #order id, collection (IF there is one associated), product name, product code
    update_column :wall_code, tmp_code.join('/').downcase
  end
end
