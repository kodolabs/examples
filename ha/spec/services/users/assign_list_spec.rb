require 'rails_helper'

describe Users::AssignList do
  let!(:user) { create :user, role: :admin }
  let!(:user2) { create :user, role: :tech }
  let!(:user3) { create :user, role: :account_manager }

  describe 'should return array of users' do
    context 'that has a task policy' do
      it 'with current user as first element' do
        result = Users::AssignList.new(user).call
        expect(result.count).to eq 2
        expect(result[0].first).to eq I18n.t('tasks.assign_to_me')
        expect(result[0].second).to eq user.id
        expect(result[1].first).to eq user2.name
        expect(result[1].second).to eq user2.id
      end
    end
  end
end
