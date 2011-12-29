include ActionView::Helpers::NumberHelper

class Admin::OfflinePaymentsController < Admin::BaseController

  before_filter :load_payment_methods, :only => [:new, :create]

  def new
    @offline_payment = OfflinePayment.new :purchased_at => Date.today
  end

  def create
    @offline_payment = resource
    if @offline_payment.save
      flash[:notice] = 'Successfully created new payment'
      redirect_to admin_purchases_path
    else
      flash[:notice] = 'Payment was not saved'
      render :action => :new
    end
  end

protected

  def resource
    OfflinePayment.factory(params['offline_payment']['reference_number'], params['offline_payment'])
  end

  def load_payment_methods
    @payment_methods = Purchase::ORGANISATION_PAYMENT_METHODS
    @payment_methods.delete(:card)
    @payment_methods.delete(:credit)
  end

end
