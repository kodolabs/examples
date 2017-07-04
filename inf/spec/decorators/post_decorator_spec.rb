require 'rails_helper'

describe PostDecorator do
  context 'show article content' do
    specify 'success' do
      post = create(:post, title: 'a', description: 'b', link: 'a')
      expect(post.decorate.show_article_content?).to be_truthy
    end

    specify 'fail' do
      post = create(:post, title: 'a', description: nil)
      expect(post.decorate.show_article_content?).to be_falsey
    end
  end

  context 'strip html in content' do
    specify 'not encoded' do
      post = build(:post, content: "<a href='http://google.com'></a>")
      p = post.decorate
      expect(p.stripped_content.blank?).to eq(true)
      expect(p.truncated_content).to eq 'No content'
    end

    specify 'encoded' do
      post = build(:post, content: "&lt;a href='https://t.co/oKd7UPO56a'&gt;&lt;/a&gt;")
      p = post.decorate
      expect(p.stripped_content.blank?).to eq(true)
      expect(p.truncated_content).to eq 'No content'
    end
  end

  context 'facebook handle' do
    specify 'with handle' do
      page = build(:page, handle: 'awesome')
      post = build(:post, page: page)
      expect(post.decorate.facebook_handle).to eq '/awesome'
    end

    specify 'with uid' do
      page = build(:page, handle: nil, uid: '11')
      post = build(:post, page: page)
      expect(post.decorate.facebook_handle).to eq '/11'
    end
  end
end
