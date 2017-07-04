require 'rails_helper'

describe Hosts::CreateHost do
  let!(:domain) { create :domain, name: 'google.com', status: :pending }

  describe '.call' do
    context 'success' do
      it 'should crete host with blog' do
        Hosts::CreateHost.new(domain, {}).call
        expect(Host.count).to eq 1
        expect(Blog.count).to eq 1
        expect(domain.reload.status).to eq 'active'
      end

      it 'should crete host without blog' do
        blog = create :blog
        params = { blog_type: :wordpress, blog_id: blog.id }
        Hosts::CreateHost.new(domain, params).call
        expect(Host.count).to eq 1
        expect(Blog.count).to eq 1
        expect(domain.reload.status).to eq 'active'
      end
    end
  end
end
