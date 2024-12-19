class Team < ApplicationRecord
    belongs_to :user
    has_many :integrations
    has_many :charges


    def mrr ( date = Date.today )
        
        charges.where('recognition_start_date <= ? AND recognition_end_date >= ?', date, date).collect { |charge| charge.mrr }.sum
    end

    def added_amount ( date = Date.today )
        month = date.beginning_of_month
        # add up all the charges for the month
        charges.where('recognition_start_date between ? AND ?', month, month.end_of_month).sum(:amount_cents) / 100
    end

    def sources 
        charges.collect { |charge| charge.source }.uniq
    end

    def currencies
        charges.collect { |charge| charge.currency }.uniq
    end
end
