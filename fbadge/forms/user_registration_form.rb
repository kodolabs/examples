class UserRegistrationForm < Rectify::Form
  attribute :email, String
  attribute :name, String
  attribute :surname, String
  attribute :phone, String
  attribute :password, String
  attribute :password_confirmation, String

  attribute :token, String

  validates :email, :name, :surname, :phone, :token, presence: true
  validates :password,
    confirmation: :true,
    presence: true,
    length: { in: 8..32 }

  validate :email_uniqueness

  private

  def email_uniqueness
    return if User.where(email: email).none?
    errors.add :email, I18n.t('errors.already_in_use')
  end
end
