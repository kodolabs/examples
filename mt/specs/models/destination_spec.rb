require 'rails_helper'

describe Destination do
  it { should belong_to(:location) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:text) }
  it { should validate_presence_of(:location_id) }
  it { should validate_presence_of(:image) }
end
