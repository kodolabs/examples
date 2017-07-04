class AuthenticationController < ApplicationController
  def create
    ::Integrations::Eventbrite::Authorize.call(current_user, auth_hash) do
      on(:invalid) { redirect_to root_path, flash: { warning: 'There was an error while trying to authenticate you...' } }
      on(:ok) do
        ::Integrations::Eventbrite::CreateWebhooks.call(current_user)
        redirect_to profile_accounts_path, flash: { success: 'You have successfully authorized.' }
      end
    end
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
