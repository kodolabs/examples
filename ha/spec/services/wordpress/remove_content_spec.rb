require 'rails_helper'

describe Wordpress::RemoveContent do
  let!(:domain) { create :domain, name: 'google.com' }
  let!(:blog) { create :blog }
  let!(:host) do
    create :host,
      domain: domain,
      active: true, blog: blog,
      blog_type: :wordpress,
      sync_mode: :wordpress_api,
      wp_auth_plugin: true
  end

  describe 'remove content' do
    it 'success' do
      allow_any_instance_of(WP::API::Client).to receive(:delete_post).and_return(true)
      allow_any_instance_of(WP::API::Client).to receive(:posts)
        .with(page: 1, should_raise_on_empty: false)
        .and_return([OpenStruct.new(id: 1)])
      allow_any_instance_of(WP::API::Client).to receive(:posts)
        .with(page: 2, should_raise_on_empty: false)
        .and_return([])

      expect(Wordpress::RemoveContent.new(host).call).to be_nil
    end

    it 'error' do
      allow_any_instance_of(WP::API::Client).to receive(:posts).and_raise('Invalid request')

      expect(host.last_error.blank?).to be_truthy
      Wordpress::RemoveContent.new(host).call
      expect(host.reload.last_error.blank?).to be_falsey
      expect(host.last_error).to eq 'WP remove content: Invalid request'
    end
  end
end
