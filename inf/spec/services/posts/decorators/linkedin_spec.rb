require 'rails_helper'

describe Posts::Decorators::Linkedin do
  let(:service) { Posts::Decorators::Linkedin }

  context 'success' do
    specify 'decorate' do
      uid = SecureRandom.hex
      text = SecureRandom.hex
      picture_url = FFaker::Internet.http_url
      posted_at = Time.new.to_i
      likes_count = 2
      comments_count = 3
      content = {
        'comment' => text,
        'content' => { 'submittedImageUrl' => picture_url },
        'timestamp' => posted_at * 1000
      }

      post1 = {
        'updateKey' => uid,
        'updateContent' => {
          'companyStatusUpdate' => { 'share' => content }
        },
        'numLikes' => likes_count,
        'updateComments' => { '_total' => comments_count }
      }

      values = [post1]
      api_data = { 'values' => values }

      valid_data = OpenStruct.new(
        uid: uid,
        content: text,
        picture: picture_url,
        posted_at: Time.zone.at(posted_at).to_datetime,
        likes_count: likes_count,
        comments_count: comments_count
      )

      decorated = service.new(api_data).call
      expect(decorated).to eq [valid_data]
    end
  end
end
