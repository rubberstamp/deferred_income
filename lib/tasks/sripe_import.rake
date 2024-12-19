# lib/tasks/sripe_import.rake

require 'stripe'
require 'dotenv/load'
require 'csv'
require 'time'
require 'date'
require 'json'

namespace :stripe do
  desc "Import charges from Stripe API"
  task import_charges: :environment do
    Stripe.api_key = ENV['STRIPE_API_KEY']

    CACHE_FILE = "#{Rails.root}/tmp/charges_cache.json"

    def beginning_of_month(date)
      Date.new(date.year, date.month, 1)
    end

    def months_between(start_date, end_date)
      ((end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)).abs + 1
    end

    def next_month(date)
      date.month == 12 ? Date.new(date.year + 1, 1, 1) : Date.new(date.year, date.month + 1, 1)
    end

    def calculate_monthly_amounts(amount, start_date, end_date)
      return {} if start_date.nil? || end_date.nil?

      start_date = start_date.to_date
      end_date = end_date.to_date
      num_months = months_between(start_date, end_date)
      monthly_amount = amount.to_f / num_months

      amounts = {}
      current_date = beginning_of_month(start_date)

      while current_date <= beginning_of_month(end_date)
        month_key = current_date.strftime("%Y-%m")
        amounts[month_key] = monthly_amount.round(2)
        current_date = next_month(current_date)
      end

      amounts
    end

    def fetch_charges_with_service_periods
      all_charges = []
      one_year_ago = Time.now.to_i - (365 * 24 * 60 * 60)
      today = Time.now.to_i

      has_more = true
      starting_after = nil

      while has_more
        charges = Stripe::Charge.list(
          limit: 100,
          created: { gte: one_year_ago },
          starting_after: starting_after
        )

        charges.data.each do |charge|
          if charge.invoice
            invoice = Stripe::Invoice.retrieve(charge.invoice)
            period_end = invoice.lines.data.first.period.end
            period_start = invoice.lines.data.first.period.start

            if (period_end && period_end > today) or (period_start.blank? )
              start_date = Time.at(period_start)
              end_date = Time.at(period_end)
              monthly_amounts = calculate_monthly_amounts(charge.amount / 100.0, start_date, end_date)

              # Check for existing charge by transaction_id
              existing_charge = Charge.find_by(transaction_id: charge.id)

              unless existing_charge
                customer = charge.customer ? Stripe::Customer.retrieve(charge.customer) : nil
                customer_email = customer ? customer.email : 'N/A'

                all_charges << {
                  source: 'Stripe',
                  transaction_id: charge.id,
                  amount: charge.amount / 100.0,
                  currency: charge.currency.downcase,
                  description: "Customer Email: #{customer_email}",
                  recognition_start_date: start_date,
                  recognition_end_date: end_date,
                  monthly_amounts: monthly_amounts
                }
              end
            end
          end
        end

        has_more = charges.has_more
        starting_after = charges.data.last&.id if has_more
        sleep(0.5) if has_more
      end

      all_charges
    end

    puts "Fetching Stripe charges..."
    stripe_charges = fetch_charges_with_service_periods

    stripe_charges.each do |charge_data|
      Charge.create!(
        team_id: 1,  # Adjust as necessary
        source: charge_data[:source],
        transaction_id: charge_data[:transaction_id],
        amount: charge_data[:amount],
        currency: charge_data[:currency],
        description: charge_data[:description], # Now includes customer email
        recognition_start_date: charge_data[:recognition_start_date],
        recognition_end_date: charge_data[:recognition_end_date]
      )
    end

    puts "Charges imported successfully!"
  end
end