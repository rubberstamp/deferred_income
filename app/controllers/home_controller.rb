class HomeController < ApplicationController

  before_action :authenticate_user!, except: [:index]
  before_action :has_a_team?, except: [:index]

  def index
    redirect_to '/dashboard' if signed_in?
  end

  def dashboard
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
      month = current_month
      mrr = current_user.current_team.mrr(current_month)
      added_amount = current_user.current_team.added_amount(current_month)
      # add month and mrr to @mrr_by_month
      @mrr_by_month[month] = { mrr: mrr, added_amount: added_amount }
      current_month = current_month.next_month
    end
  end


end
