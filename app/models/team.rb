class Team < ApplicationRecord
    belongs_to :user
    has_many :integrations
    has_many :charges


    def mrr ( date = Date.today )
        charges.where('recognition_start_date <= ? AND recognition_end_date >= ?', date, date).collect { |charge| charge.mrr }.sum
    end

    def sources 
        charges.collect { |charge| charge.source }.uniq
    end

    def currencies
        charges.collect { |charge| charge.currency }.uniq
    end
end
