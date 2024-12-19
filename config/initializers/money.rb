MoneyRails.configure do |config|
    config.default_currency = :usd
    config.add_rate("USD", "EUR", 0.85)
    config.add_rate("EUR", "USD", 1.18)
    config.add_rate("GBP", "USD", 1.31)
    config.add_rate("USD", "GBP", 0.76)
    config.add_rate("GBP", "EUR", 1.14)
    config.add_rate("EUR", "GBP", 0.88)
end
  