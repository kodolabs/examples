class PatientDecorator < Draper::Decorator
  delegate_all

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_official
    "#{last_name}, #{first_name}"
  end

  def address_with_city
    return 'N/A' unless address.present? || city.present?
    [address, city].map(&:presence).compact.join(', ')
  end

  def full_address
    return unless address.present? || city.present?
    [address, city, country_name].map(&:presence).compact.join(', ')
  end

  def billing_address
    address_with_city
  end

  def country_name
    return if object.country.blank?
    ISO3166::Country[object.country].name
  end

  def email_link(css_class = '')
    h.link_to object.email, "mailto:#{object.email}", class: css_class
  end

  def phone_link(css_class = '')
    return if phone.blank?
    h.link_to phone, "tel:#{phone}", class: css_class
  end

  def credit_cards
    cards = object.credit_cards.all.map { |c| [c.title, c.id] }
    cards << ['Another Credit Card', '']
  end

  def age
    h.pluralize(object.age, 'year') + ' old'
  end

  def dob
    "#{object.birth_date.strftime('%-d %B %Y')} (<small>#{age}</small>)".html_safe
  end
end
