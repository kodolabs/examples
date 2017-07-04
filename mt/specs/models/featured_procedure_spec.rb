require 'rails_helper'

describe FeaturedProcedure do
  it { should belong_to(:procedure) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:procedure_id) }
end
