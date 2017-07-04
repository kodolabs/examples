require 'rails_helper'

describe Linkedin::Analytics do
  let(:service) { Linkedin::Analytics }
  context 'success' do
    specify 'updates analytics' do
      from = DateTime.strptime('12.07.1994', '%d.%m.%Y').utc.to_time.to_i
      to = DateTime.strptime('11.07.1994', '%d.%m.%Y').utc.to_time.to_i
      page = { 'id' => 1231 }
      path = "https://api.linkedin.com/v1/companies/#{page.fetch('id')}/historical-status-update-statistics"
      fields = '(time,like-count,impression-count,share-count,comment-count)'
      params = "end-timestamp=#{to * 1000}&format=json&start-timestamp=#{from * 1000}&time-granularity=day"
      url = "#{path}:#{fields}?#{params}"

      values = [
        {
          'clickCount' => 1,
          'commentCount' => 2,
          'impressionCount' => 3,
          'likeCount' => 8,
          'shareCount' => 4,
          'time' => from * 1000
        },
        {
          'clickCount' => 1,
          'commentCount' => 6,
          'impressionCount' => 5,
          'likeCount' => 2,
          'shareCount' => 3,
          'time' => to * 1000
        }
      ]

      stub_response = { 'values' => values }

      stub_request(:get, url).to_return(body: stub_response.to_json)

      valid_result = {
        labels: ['1994-07-12', '1994-07-11'],
        likes: [8, 2],
        shares: [4, 3],
        impressions: [3, 5],
        comments: [2, 6]
      }

      result = service.new('test_token').updates_analytics(page, from, to_timestamp: to)

      expect(result).to eq(valid_result)
    end
  end
end
