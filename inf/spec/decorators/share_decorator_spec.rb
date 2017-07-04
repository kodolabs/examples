require 'rails_helper'

describe ShareDecorator do
  context 'cannot be editable' do
    specify 'posted' do
      share = build(:share, scheduled_at: nil)
      expect(share.decorate.cannot_be_editable?).to be_truthy
    end

    specify 'scheduled' do
      share = build(:share, :scheduled)
      expect(share.decorate.cannot_be_editable?).to be_falsey
    end

    specify 'expired' do
      share = build(:share, scheduled_at: Time.current - 2.days)
      expect(share.decorate.cannot_be_editable?).to be_truthy
    end
  end
end
