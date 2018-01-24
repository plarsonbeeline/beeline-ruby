class FinancialReport
  def initialize(user_id: nil, currency: Money.default_currency, after_at: nil, counts: {}, amounts: {})
    @user_id = user_id
    @currency = Money::Currency.wrap(currency)
    @after_at = after_at
    @counts = counts
    @amounts = amounts
  end

  attr_reader :user_id, :currency, :after_at, :counts, :amounts

  def count(k)
    counts[k] || 0
  end

  def amount(k)
    amounts[k] || Money.new(0, currency)
  end
end