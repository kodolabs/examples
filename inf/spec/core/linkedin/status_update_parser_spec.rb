require 'rails_helper'

describe Linkedin::StatusUpdateParser do
  it 'parses empty request' do
    values = []

    valid_result = {
      labels: [],
      likes: [],
      shares: [],
      impressions: [],
      comments: []
    }

    expect(Linkedin::StatusUpdateParser.parse_status_updates('values' => values)).to eq(valid_result)
  end

  it 'parses one result' do
    t1 = DateTime.strptime('12.07.1994', '%d.%m.%Y').utc.to_time.to_i
    values = [
      {
        'clickCount' => 1,
        'commentCount' => 2,
        'impressionCount' => 3,
        'likeCount' => 8,
        'shareCount' => 4,
        'time' => t1 * 1000
      }
    ]

    valid_result = {
      labels: ['1994-07-12'],
      likes: [8],
      shares: [4],
      impressions: [3],
      comments: [2]
    }

    expect(Linkedin::StatusUpdateParser.parse_status_updates('values' => values)).to eq(valid_result)
  end

  it 'parses more results' do
    t1 = DateTime.strptime('12.07.1994', '%d.%m.%Y').utc.to_time.to_i
    t2 = DateTime.strptime('11.07.1994', '%d.%m.%Y').utc.to_time.to_i
    values = [
      {
        'clickCount' => 1,
        'commentCount' => 2,
        'impressionCount' => 3,
        'likeCount' => 8,
        'shareCount' => 4,
        'time' => t1 * 1000
      },
      {
        'clickCount' => 1,
        'commentCount' => 6,
        'impressionCount' => 5,
        'likeCount' => 2,
        'shareCount' => 3,
        'time' => t2 * 1000
      }
    ]

    valid_result = {
      labels: ['1994-07-12', '1994-07-11'],
      likes: [8, 2],
      shares: [4, 3],
      impressions: [3, 5],
      comments: [2, 6]
    }

    expect(Linkedin::StatusUpdateParser.parse_status_updates('values' => values)).to eq(valid_result)
  end
end
