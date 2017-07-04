FactoryGirl.define do
  factory :enquiry do
    demand
    hospital

    trait :preop do
      workflow_state 'preop'
    end

    trait :pending do
      workflow_state :pending
    end

    trait :enquiry_declined do
      workflow_state 'enquiry_declined'
      state_comment 'reject reason message'
    end

    trait :enquiry_cancelled do
      workflow_state 'enquiry_cancelled'
    end

    trait :proposed do
      workflow_state 'proposed'
    end

    trait :proposal_rejected do
      workflow_state 'proposal_rejected'
    end

    trait :proposal_cancelled do
      workflow_state 'proposal_cancelled'
    end

    trait :proposal_rejected do
      workflow_state 'proposal_rejected'
    end

    trait :proposal_accepted do
      workflow_state 'proposal_accepted'
    end

    trait :card_authorized do
      workflow_state 'card_authorized'
    end

    trait :payment_requested do
      workflow_state 'payment_requested'
    end

    trait :payment_cancelled do
      workflow_state 'payment_cancelled'
    end

    trait :payment_made do
      workflow_state 'payment_made'
    end
  end
end
