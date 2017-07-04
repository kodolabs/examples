require 'rails_helper'

RSpec.describe Blog, type: :model do
  describe 'check synced status' do
    it 'should be synced without articles' do
      blog = create :blog
      expect(blog.not_synced?).to be_falsey
    end

    it 'should be synced with draft articles' do
      blog = create :blog
      create :article, publishing_status: :draft, blog: blog
      create :article, publishing_status: :future, blog: blog
      create :article, publishing_status: :private, blog: blog
      expect(blog.not_synced?).to be_falsey
    end

    it 'should be not synced' do
      blog = create :blog
      create :article, publishing_status: :publish, blog: blog
      expect(blog.reload.not_synced?).to be_truthy

      create :article, publishing_status: :pending, blog: blog
      expect(blog.reload.not_synced?).to be_truthy
    end
  end
end
