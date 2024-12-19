require 'csv'
class ChargesController < ApplicationController
  def import
    if params[:file].present?
      CSV.foreach(params[:file].path, headers: true) do |row|
        current_user.current_team.charges.create!(row.to_hash)
      end
      redirect_to charges_path, notice: 'CSV imported successfully.'
    else
      redirect_to charges_path, alert: 'Please upload a valid CSV file.'
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
