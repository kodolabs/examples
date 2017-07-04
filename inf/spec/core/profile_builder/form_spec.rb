require 'rails_helper'

describe ProfileBuilder::Form do
  context 'success' do
    let(:form) { ProfileBuilder::Form }
    specify 'required attributes' do
      f = form.new
      f.validate
      required_attrs = %i(
        profession full_name date_of_birth
        contact_number country languages time_zone workplaces
      )
      expect(f.errors.keys).to match_array required_attrs
    end

    context 'profession' do
      let(:profession) { create(:profession, :nurse) }
      specify 'fail' do
        profession
        f = form.new(profession: '-1')
        f.validate
        expect(f.errors[:profession]).to eq ['is not included in the list']
      end

      specify 'success' do
        profession
        f = form.new(profession: profession.id.to_s)
        f.validate
        expect(f.errors[:profession]).to be_empty
      end
    end

    context 'validate date_of_birth' do
      specify 'success' do
        f = form.new(date_of_birth: '10/11/1991')
        f.validate
        expect(f.errors[:date_of_birth]).to be_empty
      end

      specify 'fail' do
        f = form.new(date_of_birth: '10/11/2030')
        f.validate
        expect(f.errors[:date_of_birth]).to eq ['not realistic age']
      end
    end

    context 'contact number' do
      specify 'success' do
        f = form.new(contact_number: '+1 12312312311')
        f.validate
        expect(f.errors[:contact_number]).to be_empty
      end

      specify 'fail' do
        f = form.new(contact_number: '123')
        f.validate
        expect(f.errors[:contact_number]).to include('invalid number')
      end
    end

    context 'friends emails' do
      specify 'success' do
        f = form.new(friends: ['mail@mail.com'])
        f.validate
        expect(f.errors[:friends]).to be_empty
      end

      specify 'fail' do
        f = form.new(friends: ['mail@mail'])
        f.validate
        expect(f.errors[:friends]).to eq ['is invalid']
      end
    end
  end
end
