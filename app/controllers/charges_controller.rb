require 'csv'
class ChargesController < ApplicationController

    # make sure they are logged in
    before_action :authenticate_user!
    before_action :has_a_team?, except: [:index]



    

  def import
    if params[:file].present?
      begin
        CSV.foreach(params[:file].path, headers: true) do |row|
          charge_params = {
            team_id: current_user.current_team.id,
            source: row['source'],
            transaction_id: row['transaction_id'],
            amount: row['amount'],
            currency: row['currency'],
            recognition_start_date: row['recognition_start_date'],
            recognition_end_date: row['recognition_end_date']
          }
  
          charge = current_user.current_team.charges.new(charge_params)
  
          unless charge.save
            # Log errors for this charge
            logger.error("Failed to save charge: #{charge.errors.full_messages.join(", ")}")
          end
        end
  
        redirect_to charges_path, notice: 'Charges were successfully imported.'
      rescue StandardError => e
        redirect_to new_charge_path, alert: "An error occurred: #{e.message}"
      end
    else
      redirect_to new_charge_path, alert: "Please upload a file."
    end
  end

  def create
    @charge = current_user.current_team.charges.new(charge_params)
    if @charge.save
      redirect_to charges_path, notice: 'Charge was successfully created.'
    else
      render :new
    end
  end

  def index
    @charges = current_user.current_team.charges

    if params[:date].present?
      date = Date.parse(params[:date])
      @charges = @charges.where('recognition_start_date <= ? AND recognition_end_date >= ?', date, date)
    end
    # filter on source
    if params[:source].present?
      @charges = @charges.where(source: params[:source])
    end

    if params[:sources].present?
      @charges = @charges.where(source: params[:sources])
    end


    respond_to do |format|
      format.csv do
        send_data charges_to_csv(@charges), filename: "charges-#{DateTime.now.strftime("%Y-%m-%d-%H-%M-%S")}.csv", type: :csv
      end
        @count = @charges.where("amount > ?", 0).count
        @mrr = @charges.collect { |charge| charge.mrr }.sum
        @charges = @charges.order(recognition_start_date: :asc).page(params[:page]).per(100)
        @added_amount = @charges.collect { |charge| charge.usd_amount }.sum
        if date.present?
          @added_amount = current_user.current_team.charges.where('recognition_start_date between ? AND ?', date.beginning_of_month, date.end_of_month).sum(:amount_cents) / 100
        else
          @added_amount = current_user.current_team.charges.sum(:amount_cents) / 100
        end
        format.html
    end
  end

  def new
    @charge = Charge.new
  end

  def edit
    @charge = current_user.current_team.charges.find(params[:id])
  end

  def update
    @charge = current_user.current_team.charges.find(params[:id])
    if @charge.update(charge_params)
      redirect_to charges_path, notice: 'Charge was successfully updated.'
    else
      render :edit
    end
  end

  private
  def charge_params
    params.require(:charge).permit(:source, :transaction_id, :split_transaction_id, :booked_date, :recognition_start_date, :recognition_end_date, :amount, :currency, :description)
  end
end

def charges_to_csv(charges)
    CSV.generate(headers: true) do |csv|
      csv << ["Source", "Transaction ID", "Amount", "Currency", "Recognition Start Date", "Recognition End Date"]
      charges.each do |charge|
        csv << [charge.source, charge.transaction_id, charge.amount, charge.currency, charge.recognition_start_date, charge.recognition_end_date]
      end
    end
  end
