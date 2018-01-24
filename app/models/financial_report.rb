class FinancialReport
  def initialize(user_id: nil, currency: Money.default_currency, after_at: nil, counts: {}, amounts: {})
    self.user_id = user_id
    self.currency = Money::Currency.wrap(currency)
    self.after_at = after_at
    self.counts = counts
    self.amounts = amounts
  end

  attr_accessor :user_id, :currency, :after_at, :counts, :amounts

  def count(k)
    counts[k] || 0
  end

  def amount(k)
    amounts[k] || Money.new(0, currency)
  end
end