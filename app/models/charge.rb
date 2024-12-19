class Charge < ApplicationRecord

  belongs_to :team

  monetize :amount_cents, with_model_currency: :currency



    def usd_amount
        amount.exchange_to('USD').amount
    end


    def mrr 
        return 0 if self.recognition_start_date.nil? || self.recognition_end_date.nil?
        usd_amount / months
    end


    def months
        # number of months between start and end date
        months = (self.recognition_end_date - self.recognition_start_date).to_i / 30
    end


    

end

