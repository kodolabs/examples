require 'rails_helper'

describe Profiles::Form do
  let(:customer) { create(:customer, :with_user) }
  let(:user) { customer.primary_user }
  let(:profile) { customer.profile }
  let(:form) { Profiles::Form }

  def empty_params
    { customer: customer, form: {} }
  end

  def params(attrs = {})
    empty_params.deep_merge(form: attrs)
  end

  context 'user model attributes' do
    specify 'without password fields' do
      p = params(time_zone: 'US', email: 'test@mail.com')
      f = form.from_params(p)
      expect(f.user_model_attributes.keys).to match_array %i(email)
    end

    specify 'with password fields' do
      p = params(time_zone: 'US', email: 'test@mail.com', password: 123_456, password_confirmation: 123_456)
      f = form.from_params(p)
      expect(f.user_model_attributes.keys).to match_array %i(email password password_confirmation)
    end
  end

  specify 'customer model attributes' do
    p = { logo: '123.jpg', logo_cache: '/tmp/123.jpg' }
    f = form.from_params(p)
    expect(f.customer_model_attributes.keys).to match_array %i(logo logo_cache)
  end

  specify 'languages present' do
    p = { languages: [''], customer: customer }
    f = form.from_params(p)
    expect(f.valid?).to be_falsey
    expect(f.errors[:languages]).to be_truthy
  end

  context 'logo_preview' do
    specify 'on invalid' do
      p = { logo_url: 'images/123.jpg' }
      f = form.from_params(p)
      expect(f.logo_preview).to eq('images/123.jpg')
    end

    specify 'on initialize from db' do
      logo = double('logo')
      allow(logo).to receive(:url) { 'images/456.jpg' }
      f = form.new(logo: logo)
      expect(f.logo_preview).to eq('images/456.jpg')
    end
  end

  specify 'passwords are not equal' do
    p = params(password: 123, password_confirmation: 456)
    f = form.from_params(p)
    expect(f.valid?).to be_falsey
    errors = f.errors.full_messages
    expect(errors).to include 'Password confirmation is invalid'
    expect(errors).to include 'Password is invalid'
  end

  context 'date of birth' do
    context 'from params' do
      specify 'empty' do
        f = form.from_params(params)
        expect(f.date_of_birth).to be_falsey
      end

      specify 'present' do
        f = form.from_params(params(date_of_birth: '1991-11-20'))
        expect(f.date_of_birth).to eq Date.parse('20/11/1991')
      end
    end
  end

  context 'validation' do
    specify 'required fields' do
      f = form.from_params({}, customer: customer)
      expect(f.valid?).to be_falsey
      required_attributes = %i(
        profession_id full_name date_of_birth
        phone country time_zone languages
      )
      expect(f.errors.keys).to match_array(required_attributes)
    end
  end

  specify 'formatted date_of_birth' do
    f = form.new(customer: customer, date_of_birth: Date.parse('1991-11-20'))
    expect(f.formatted_date_of_birth).to eq '20/11/1991'
  end

  context 'topics presence for profession' do
    let(:s) { create(:topic, :speciality) }

    context 'has_topics' do
      let(:p) { create(:profession, :is_active, title: 'With topics') }

      specify 'success' do
        f = form.new(profession_id: p.id.to_s, speciality_topics: [s.id])
        f.validate
        expect(f.errors[:speciality_topics]).to be_empty
      end

      specify 'fail' do
        f = form.new(profession_id: p.id.to_s)
        f.validate
        expect(f.errors[:speciality_topics]).to eq ["can't be blank"]
      end
    end

    context 'has no topics' do
      let(:p) { create(:profession, :not_active, title: 'Without topics') }

      specify 'success' do
        f = form.new(profession_id: p.id.to_s)
        f.validate
        expect(f.errors[:speciality_topics]).to be_empty
        expect(f.errors[:profession_id]).to be_empty
      end

      specify 'fail' do
        f = form.new(profession_id: p.id.to_s, speciality_topics: [s.id])
        f.validate
        expect(f.errors[:speciality_topics]).to be_empty
        expect(f.errors[:profession_id]).to eq ["can't have topics"]
      end
    end
  end
end
