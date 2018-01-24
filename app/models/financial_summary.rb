class FinancialSummary
  def initialize(user_id: nil, currency: Money.default_currency)
    self.user_id = user_id
    self.currency = Money::Currency.wrap(currency)
  end

  attr_accessor :user_id, :currency

  def report(after_at = nil)
    report = Transaction
                 .select('transactions.category, count(*) as num')
                 .select("SUM(CASE WHEN transactions.action = 'debit' THEN transactions.amount_cents * -1.0
                                   ELSE transactions.amount_cents
                                   END) as amount")
                 .group(:category)
                 .where(user_id: user_id, amount_currency: currency.iso_code)
    report = report.where('created_at >= ?', after_at) if after_at.present?
    counts = report.collect { |c| [ c['category'].to_sym, c['num'] ] }
    amounts = report.collect { |c| [ c['category'].to_sym, Money.new(c['amount'], currency) ] }
    FinancialReport.new(
        user_id: user_id,
        currency: currency,
        after_at: after_at,
        counts: Hash[*counts.flatten],
        amounts: Hash[*amounts.flatten]
    )
  end

  def one_day
    report Time.now - 1.day
  end

  def seven_days
    report Time.now - 7.days
  end

  def lifetime
    report
  end
end