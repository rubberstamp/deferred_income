class HomeController < ApplicationController
  def index
    # a table with months and mrr
    start_date = current_user.current_team.charges.minimum(:recognition_start_date)
    end_date = current_user.current_team.charges.maximum(:recognition_end_date)

    # set start date to last month and end date to next year
    start_date = Date.today - 1.month
    end_date = Date.today + 1.year
    @mrr_by_month = {}
    # set @mrr_by_month to a hash of months and mrr
    current_month = start_date
    while( current_month <= end_date )
      @mrr_by_month[current_month] = current_user.current_team.mrr(current_month)
      current_month = current_month.next_month
    end
  end
end
