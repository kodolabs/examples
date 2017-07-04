require 'rails_helper'

describe Users::UserForm do
  let(:form) { Users::UserForm }
  context 'success' do
    context 'password length' do
      let(:error) { "Password is too short (minimum is #{User.password_length.min} characters)" }
      specify 'success' do
        f = form.new(password: 'aaaaaaa', password_confirmation: 'aaaaaaa')
        expect(f.valid?).to be_falsey
        expect(f.errors.full_messages).not_to include error
      end

      specify 'fail' do
        f = form.new(password: 1, password_confirmation: 1)
        expect(f.valid?).to be_falsey
        expect(f.errors.full_messages).to include error
      end
    end
  end
end
