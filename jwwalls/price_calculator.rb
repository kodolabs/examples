class PriceCalculator

  UNITS_CONVERSION = {
    'mm'            => 0.001,
    'cm'            => 0.01,
    'metres'        => 1,
    'inches'        => 0.0254
  }

  WIDTH_ROUNDING    = 1.3
  WIDTH_MULTIPLIER  = 1.37
  HEIGHT_PADDING    = 1.0
  VAT               = 20 # percents
  MIN_PRICE         = 80

  DEFAULT_WIDTH     = 1.2
  DEFAULT_HEIGHT    = 2.4 # in metres

  attr_accessor :width, :height, :hq_cost, :jww_sell_price, :packing, :additional_cost, :rights_cost_value, :rights_cost_type

  def initialize(options={})
    self.width              = DEFAULT_WIDTH
    self.height             = DEFAULT_HEIGHT
    self.additional_cost    = 0
    self.rights_cost_value  = 0
    self.rights_cost_type   = 'fixed'

    options.each do |key, value|
      send "#{key}=", value
    end
  end

  def wastage
    raise('Wastage not set') if Settings.wastage.to_f == 0
    @wastage ||= Settings.wastage.to_f
  end

  def wf_value_added
    raise('"WF value added" not set') if Settings.wastage.to_f == 0
    @wf_value_added ||= Settings.wf_value_added.to_f
  end

  def postal_tubes
    raise('Postal tubes not set') if Settings.postal_tubes.to_f == 0
    @postal_tubes ||= Settings.postal_tubes.to_f
  end

  def design=(design)
    self.width    = to_metres design.wall_width, design.units
    self.height   = to_metres design.wall_height, design.units
    self.material = design.material
  end

  def product=(product)
    self.additional_cost    = product.additional_cost.to_f
    self.rights_cost_value  = product.rights_cost.to_f
    self.rights_cost_type   = product.rights_cost_type
  end

  def material=(material)
    self.hq_cost            = material.hq_cost
    self.jww_sell_price     = material.jww_sell_price
    self.packing            = material.packing_cost
  end

  def area
    (width_rounded * height_rounded * wastage).round(4)
  end

  def to_metres(value, units)
    raise ArgumentError, "Invalid units: '#{units}'" if UNITS_CONVERSION[units].blank?
    (value * UNITS_CONVERSION[units]).round(3)
  end

  def width_rounded
    raise 'Width is not set' if width.to_f == 0
    ((width.to_f / WIDTH_ROUNDING).ceil * WIDTH_MULTIPLIER).round(3)
  end

  def height_rounded
    raise 'height is not set' if height.to_f == 0
    (height.to_f + HEIGHT_PADDING).round(3)
  end

  def postal_tubes_cost
    (area / 10 * postal_tubes).ceil
  end

  def hq_total_cost
    (area * hq_cost.to_f + postal_tubes_cost).ceil
  end

  def wf_total_cost
    ((hq_total_cost.to_f / (100 - wf_value_added)) * 100.0).ceil
  end

  def base_cost
    (area * jww_sell_price.to_f + additional_cost.to_f).round(2)
  end

  def packing_cost
    (area / 10.0 * packing).ceil
  end

  def rights_cost
    if rights_cost_type == 'fixed'
      rights_cost_value.to_f
    elsif rights_cost_type == 'percent'
      (base_cost.to_f / (100 - rights_cost_value.to_f ) * rights_cost_value.to_f).round(2)
    else
      0
    end
  end

  def vat
    ((base_cost + rights_cost) * (VAT.to_f / 100.0)).round(2)
  end

  def subtotal
    base_cost + rights_cost
  end

  def total_cost
    total = subtotal + vat
    [total, MIN_PRICE].max
  end

  def price_structure
    struct = {
      area:             area,
      hq_total_cost:    hq_total_cost,
      wf_total_cost:    wf_total_cost,
      packing_cost:     packing_cost,
      base_cost:        base_cost,
      rights_cost:      rights_cost,
      vat:              VAT,
      vat_cost:         vat,
      subtotal:         subtotal,
      total_cost:       total_cost
    }

    total = struct[:total_cost]
    # recalculate rights cost based on rounded total cost
    struct[:vat_cost]     = (total - total / ((100 + VAT) / 100.0)).round(2)
    struct[:rights_cost]  = ((total - struct[:vat_cost]) * (rights_cost_value.to_f / 100.0)).round(2)
    struct[:base_cost]    = total - struct[:vat_cost] - struct[:rights_cost]
    struct[:subtotal]     = total - struct[:vat_cost]

    struct
  end

  def self.vat_rate
    VAT / 100.0
  end
end
