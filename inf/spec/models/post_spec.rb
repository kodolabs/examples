require 'rails_helper'

describe Post do
  it { should belong_to :page }

  context 'duplicates' do
    let(:page) { create(:page) }
    let(:post) { create(:post, page: page, uid: '111') }
    let(:duplicate_post) { build(:post, uid: '111', page: page) }
    let(:valid_post) { build(:post, uid: '111') }

    it 'dont create duplicates for page' do
      post
      duplicate_post.save
      expect(duplicate_post.persisted?).to eq(false)
    end

    it 'create posts with same uid on different pages' do
      post
      valid_post.save
      expect(valid_post.persisted?).to eq(true)
    end
  end
end
