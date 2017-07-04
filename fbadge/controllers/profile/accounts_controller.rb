class Profile::AccountsController < ApplicationController
  def show
    render :show, locals: { authorized: false, status: 'Not Authorized' }
  end

  def show_status
    respond_to do |format|
      format.html do
        ::Integrations::Eventbrite::CheckAuthorize.call(current_user) do
          on(:ok) { render :show, layout: false, locals: { authorized: true } }
          on(:unauthorized_user) { render :show, layout: false, locals: { authorized: false, status: 'Not Authorized' } }
          on(:invalid_token) { render :show, layout: false, locals: { authorized: false, status: 'Invalid token' } }
        end
      end
    end
  end

  def deauthorize
    ::Integrations::Eventbrite::Deauthorize.call(current_user) do
      on(:ok) { redirect_to profile_accounts_path, locals: { authorized: false }, notice: 'You deauthorized' }
      on(:invalid) { redirect_to profile_accounts_path, locals: { authorized: true }, notice: 'You are not deauthorized' }
    end
  end
end
