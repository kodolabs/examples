module Cards
  class CardForm < Rectify::Form
    attribute :name
    attribute :address
    attribute :city
    attribute :postcode
    attribute :country
    attribute :brand
    attribute :last4
    attribute :stripe_token
    attribute :stripe_id
    attribute :exp_month
    attribute :exp_year

    validates :name, :address, :city, :postcode, :country,
      :brand, :last4, :stripe_token, :stripe_id, presence: true
  end
end
