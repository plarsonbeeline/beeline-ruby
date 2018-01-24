require 'rails_helper'

describe FinancialSummary do
  let!(:user) { create(:user) }

  # Feel free to change what the subject-block returns
  subject(:cad) { FinancialSummary.new(user_id: user.id, currency: :cad) }
  subject { FinancialSummary.new(user_id: user.id, currency: :usd) }

  it 'summarizes over one day' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12, :usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10, :usd))

      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(7.67, :usd))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(5, :cad))
    end

    expect(subject.one_day.count(:deposit)).to eq(2)
    expect(subject.one_day.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))

    expect(subject.one_day.count(:purchase)).to eq(1)
    expect(subject.one_day.amount(:purchase)).to eq(Money.from_amount(7.67, :usd))

    expect(subject.one_day.count(:refund)).to eq(0)
    expect(subject.one_day.amount(:refund)).to eq(Money.from_amount(0, :usd))

    expect(cad.one_day.count(:refund)).to eq(1)
    expect(cad.one_day.amount(:refund)).to eq(Money.from_amount(5, :cad))
  end

  it 'summarizes over seven days' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12, :usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10, :usd))
    end

    Timecop.travel(Time.now - 10.days) do
      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(131, :usd))

      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(7.67, :usd))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(5, :cad))
    end

    expect(subject.seven_days.count(:deposit)).to eq(2)
    expect(subject.seven_days.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))

    expect(subject.seven_days.count(:purchase)).to eq(0)
    expect(subject.seven_days.amount(:purchase)).to eq(Money.from_amount(0, :usd))

    expect(subject.seven_days.count(:refund)).to eq(0)
    expect(subject.seven_days.amount(:refund)).to eq(Money.from_amount(0, :usd))

    expect(cad.seven_days.count(:refund)).to eq(0)
    expect(cad.seven_days.amount(:refund)).to eq(Money.from_amount(0, :cad))
  end

  it 'summarizes over lifetime' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12, :usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10, :usd))
    end

    Timecop.travel(Time.now - 30.days) do
      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(131, :usd))

      create(:transaction, user: user,
             action: :debit, category: :withdraw,
             amount: Money.from_amount(7.67, :usd))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(5, :cad))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(13.45, :usd))
    end

    expect(subject.lifetime.count(:deposit)).to eq(2)
    expect(subject.lifetime.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))

    expect(subject.lifetime.count(:purchase)).to eq(1)
    expect(subject.lifetime.amount(:purchase)).to eq(Money.from_amount(131.00, :usd))

    expect(subject.lifetime.count(:refund)).to eq(1)
    expect(subject.lifetime.amount(:refund)).to eq(Money.from_amount(13.45, :usd))

    expect(cad.lifetime.count(:refund)).to eq(1)
    expect(cad.lifetime.amount(:refund)).to eq(Money.from_amount(5, :cad))

    expect(subject.lifetime.count(:withdraw)).to eq(1)
    expect(subject.lifetime.amount(:withdraw)).to eq(Money.from_amount(-7.67, :usd))
  end
end