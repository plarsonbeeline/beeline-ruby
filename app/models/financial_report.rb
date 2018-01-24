class FinancialReport
  def initialize(user_id: nil, currency: Money.default_currency, duration: nil, counts: {}, amounts: {})
    self.user_id = user_id
    self.currency = Money::Currency.wrap(currency)
    self.counts = counts
    self.amounts = amounts
  end

  attr_accessor :user_id, :currency, :counts, :amounts

  def count(k)
    counts[k] || 0
  end

  def amount(k)
    amounts[k] || Money.new(0, currency)
  end
end