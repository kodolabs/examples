module Users
  class FindOrCreate < Rectify::Command
    def initialize(email, name, surname)
      @email = email
      @name = name
      @surname = surname
    end

    def call
      user = User.find_by(email: @email)
      return user, true if user.present?
      [create_and_invite_user(@email, @name, @surname), false]
    end

    private

    def create_and_invite_user(email, name, surname)
      user = User.create(
        email: email,
        name: name,
        surname: surname,
        phone: '-',
        password: Devise.friendly_token.first(8)
      )
      user.invite!(user)
      user
    end
  end
end
