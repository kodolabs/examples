require 'rails_helper'

describe User::ArticleImagesController, type: :controller do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }
  let(:image) { create(:article_image) }

  context 'create' do
    let(:file) do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'images', 'customer_logo.jpg')
      )
    end

    specify 'success' do
      sign_in(user)
      post :create, params: { image: file, uuid: 1 }
      expect(response.status).to eq 200
      expect(ArticleImage.count).to eq(1)
    end
  end

  context 'destroy' do
    specify 'success' do
      image
      sign_in(user)
      delete :destroy, params: { id: image.id }
      expect(response.status).to eq(200)
      expect(ArticleImage.count).to eq(0)
    end
  end
end
