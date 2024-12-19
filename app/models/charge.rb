class Charge < ApplicationRecord

  belongs_to :team


    def usd_amount
        if self.currency == "usd"
            self.amount
        elsif self.currency == "gbp"
            self.amount * 1.3
        elsif self.currency == "eur"
            self.amount * 0.9
        end
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

