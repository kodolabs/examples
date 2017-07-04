require 'rails_helper'

describe Review do
  it { should belong_to(:patient) }
  it { should belong_to(:hospital) }
  it { should belong_to(:enquiry) }
end
