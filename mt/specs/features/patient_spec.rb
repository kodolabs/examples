require 'rails_helper'

feature 'Patient' do
  let(:user)            { create :user }
  let(:patient)         { create :patient, user: user }
  let(:manager)         { create :manager }
  let(:location_parent) { create :location }
  let(:location)        { create :location, parent: location_parent }
  let(:hospital)        { create :hospital, manager: manager, location: location }
  let!(:procedure)      { create :procedure, hospitals: [hospital], parent: create(:procedure) }

  before do
    login_as user, scope: :user
  end

  specify 'can create an enquiry', :js do
    visit hospital_path hospital
    select_option('procedure_id', procedure.name)
    click_link 'Request a quote'
    within '#demand-modal' do
      fill_in 'From', with: ' ' # FIXME: the only working way to set date
      fill_in 'To', with: ' '
      select_option('demand_purpose', 'I am ready to make a booking')
      click_on 'Submit'
    end
    expect(page).to have_content 'Congratulations! Your request has been submitted.'
    expect(page).to have_content procedure.name
  end

  specify 'can see enquiry form validations', js: true do
    visit hospital_path hospital
    select_option('procedure_id', procedure.name)
    click_link 'Request a quote'
    find('.demand-modal__submit-btn').trigger('click')
    expect(page).to have_selector('.demand-modal__validation--failed', count: 2)
  end

  describe 'with demand' do
    before do
      user.patient = patient
      demand = create :demand, patient: patient, procedures: [procedure], hospitals: [hospital]
      create :preop_form, patient: patient
      @enquiry = demand.enquiries.first
    end
  
    specify 'can cancel an enquiry', :js do
      visit patient_proposals_path
      click_with_confirmation '.proposal__link'
      expect(page).to have_content 'Search Again'
      expect(page).to have_content 'Enquiry cancelled'
    end
  
    specify 'can see declined enquiry' do
      @enquiry.decline_enquiry!('decline reason')
      visit patient_proposals_path
      expect(page).to have_content 'Search Again'
      expect(page).to have_content 'Enquiry declined'
      expect(page).to have_content @enquiry.state_comment
    end
  
    describe 'proposed enquiry' do
      before do
        create :proposal, enquiry: @enquiry, with_procedures: [procedure]
        @enquiry.make_proposal!
      end
  
      specify 'can see proposal' do
        visit patient_proposals_path
        expect(page).to have_content 'Accept Proposal'
        expect(page).to have_content 'Reject Proposal'
        expect(page).to have_content "$5,000"
      end
  
      specify 'can reject proposal', :js do
        visit patient_proposals_path
        click_with_confirmation '.reject-proposal'
        expect(page).to have_content 'Search Again'
        expect(page).to have_content 'Proposal rejected'
      end
  
      specify 'can accept proposal without credit card details', :js do
        visit patient_proposals_path
        click_with_confirmation '.accept-proposal'
        expect(page).to have_content 'Authorize Credit Card'
      end
  
      specify 'can accept proposal with credit card details', :js do
        create :credit_card, patient: patient
        visit patient_proposals_path
        click_with_confirmation '.accept-proposal'
        expect(page).to have_content 'View Bookings'
      end
    end
  
    describe 'with proposal_accepted status' do
      before do
        @enquiry.make_proposal!
        create :proposal, enquiry: @enquiry, with_procedures: [procedure]
        @enquiry.accept_proposal!
        StripeMock.start
        allow_any_instance_of(StripeMock::Instance).to receive(:get_card_by_token) {
          StripeMock::Data.mock_card Stripe::Util.symbolize_names({})
        }
      end
      after { StripeMock.stop }
  
      specify 'can authorize a credit card', :js do
        visit patient_proposals_path
        click_link 'Authorize Credit Card'
        find(:css, "input[data-stripe='exp-year']").set('16')
        expect(page).to have_selector('.card-submit--disabled')
        expect(page).to have_selector('.card-input--invalid', count: 4)
  
        find(:css, "input[data-stripe='number']").set('4242424242424242')
        find(:css, "input[data-stripe='exp-month']").set('11')
        find(:css, "input[data-stripe='cvc']").set('123')
        find(:css, ".card-authorize-modal__checkbox-text").click
  
        expect(page).to_not have_selector('.card-input--invalid')
        expect(page).to have_selector('.card-input--valid', count: 4)
        expect(page).to_not have_selector('.card-submit--disabled')
        click_with_confirmation '.card-submit'
        expect(page).to have_content 'View Bookings'
      end
    end
  
    describe 'with proposal_accepted status' do
      before do
        @enquiry.update(workflow_state: 'payment_requested')
        create :proposal, enquiry: @enquiry, with_procedures: [procedure]
        create :payment_request, enquiry: @enquiry, price: 889
        StripeMock.start
        allow_any_instance_of(StripeMock::Instance).to receive(:get_card_by_token) {
          StripeMock::Data.mock_card Stripe::Util.symbolize_names({})
        }
      end
      after { StripeMock.stop }
  
      it 'can pay with existing card', :js do
        token = StripeMock.generate_card_token(last4: "9191", exp_year: 2055)
        customer = Stripe::Customer.create(source: token)
        create :credit_card,
          patient: patient,
          last_four: '9191',
          stripe_card_id: customer.sources.data.first.id
        patient.update(stripe_id: customer.id)
  
        visit patient_bookings_path
        click_link 'View & pay invoice'
        find(:css, ".payment-modal__checkbox-text").click
        select 'VISA ***9191', from: 'Select payment method'
        click_with_confirmation '.card-submit'
  
        expect(page).to have_content("Payment was successfully made.")
      end
  
      it 'can pay with new card', :js do
        visit patient_bookings_path
        click_link 'View & pay invoice'
        select 'Another Credit Card', from: 'Select payment method'
        find(:css, "input[data-stripe='number']").set('4242424242424242')
        find(:css, "input[data-stripe='exp-year']").set('17')
        find(:css, "input[data-stripe='exp-month']").set('1')
        find(:css, "input[data-stripe='cvc']").set('123')
        find(:css, ".payment-modal__checkbox-text").click
        click_with_confirmation '.card-submit'
  
        expect(page).to have_content("Payment was successfully made.")
      end
  
      it 'can\'t see upgrade to plus button if hospital is not plus' do
        visit patient_bookings_path
        expect(page).to_not have_link('Upgrade to PLUS+')
      end
  
      it 'can visit payments refund page', :js do
        visit patient_bookings_path
        click_link 'View & pay invoice'
        expect(page).to have_link('Terms & Conditions', href: payments_and_refund_policy_terms_path)
      end
  
      describe 'Plus upgrade payment', :js do
        before do
          hospital.update_attribute(:plus_partner, true)
        end
  
        it 'can pay with existing card', :js do
          token = StripeMock.generate_card_token(last4: "9191", exp_year: 2055)
          customer = Stripe::Customer.create(source: token)
          create :credit_card,
            patient: patient,
            last_four: '9191',
            stripe_card_id: customer.sources.data.first.id
          patient.update(stripe_id: customer.id)
  
          visit patient_bookings_path
          click_link 'Upgrade to PLUS+'
          find(:css, ".payment-modal__checkbox-text").click
          select 'VISA ***9191', from: 'Select payment method'
          click_with_confirmation '.card-submit'
  
          expect(page).to have_content("Payment was successfully made.")
          expect(page).to have_content('Plus Member')
        end
  
        it 'can pay with new card', :js do
          visit patient_bookings_path
          click_link 'Upgrade to PLUS+'
          select 'Another Credit Card', from: 'Select payment method'
          find(:css, "input[data-stripe='number']").set('4242424242424242')
          find(:css, "input[data-stripe='exp-year']").set('17')
          find(:css, "input[data-stripe='exp-month']").set('1')
          find(:css, "input[data-stripe='cvc']").set('123')
          find(:css, ".payment-modal__checkbox-text").click
          click_with_confirmation '.card-submit'
  
          expect(page).to have_content("Payment was successfully made.")
          expect(page).to have_content('Plus Member')
        end
  
        it 'can be upgrade for PLUS+', :js do
          visit patient_bookings_path
          click_link 'View & pay invoice'
          sleep 0.3
          expect(page).to have_content 'Upgrade me'
        end
  
        it 'can\'t be upgrade for PLUS+', :js do
          @enquiry.update_attribute(:plus, true)
          visit patient_bookings_path
          click_link 'View & pay invoice'
          sleep 0.3
          expect(page).not_to have_content 'Upgrade me'
        end
  
        it 'can show upgrade for PLUS+ modal', :js do
          visit patient_bookings_path
          click_link 'View & pay invoice'
          sleep 0.3
          click_link 'Upgrade me'
          expect(page).to have_content 'Make a payment'
        end
  
        it 'can visit payments refund page', :js do
          visit patient_bookings_path
          click_link 'View & pay invoice'
          sleep 0.3
          expect(page).to have_link('Terms & Conditions', href: payments_and_refund_policy_terms_path)
        end
      end
    end
  end
end
