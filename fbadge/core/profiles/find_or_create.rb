module Profiles
  class FindOrCreate < Rectify::Command
    def initialize(email, name, surname, company, job_title, event)
      @email = email
      @name = name
      @surname = surname
      @company = company
      @job_title = job_title
      @event = event
    end

    def call
      user = @email.blank? ? nil : find_or_create_user
      profile = create_profile(user)
      ProfileMailer.new_profile(user, profile, @event).deliver_now if user.present?
      profile
    end

    private

    def profile_exist?
      Profile.find_by(event: @event, user: @user)
    end

    def find_or_create_user
      user, = Users::FindOrCreate.new(@email, @name, @surname).call
      profile_exist? ? nil : user
    end

    def create_profile(user)
      Profile.create(
        name: @name,
        surname: @surname,
        event: @event,
        user: user,
        role: 0,
        company: @company,
        job_title: @job_title
      )
    end
  end
end
