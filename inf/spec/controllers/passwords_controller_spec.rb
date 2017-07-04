require 'rails_helper'

describe PasswordsController, type: :controller do
  context 'edit' do
    before(:each) { @request.env['devise.mapping'] = Devise.mappings[:user] }

    context 'fail' do
      specify 'invalid token' do
        get :edit, params: { reset_password_token: 123 }
        expect(response).to redirect_to(new_user_session_path)
      end

      specify 'without token' do
        get :edit
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'success' do
      let(:user) { create(:user) }
      let(:token) { user.send_reset_password_instructions }
      let(:subject) { get :edit, params: { reset_password_token: token } }
      specify 'valid token' do
        expect(subject).to render_template('edit')
        expect(response.status).to eq(200)
      end
    end
  end
end
