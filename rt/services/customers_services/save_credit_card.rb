module CustomersServices
  class SaveCreditCard
    def initialize(params, customer)
      @params = params
      @customer = customer
    end

    def call
      credit_card = @customer.credit_card.present? ? @customer.credit_card : @customer.build_credit_card
      credit_card.attributes = card_data
      credit_card.save
    end

    private

    def card_data
      {
        name: @params[:card][:name],
        exp_date: exp_date,
        system: @params[:card][:system],
        last_four: @params[:card][:number].to_s.split(//).last(4).join
      }
    end

    def exp_date
      "#{month}/#{year}"
    end

    def month
      @params[:card][:month].rjust(2, '0')
    end

    def year
      @params[:card][:year].to_s.split(//).last(2).join
    end
  end
end
