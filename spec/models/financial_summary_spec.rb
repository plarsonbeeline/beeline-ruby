require 'rails_helper'

describe FinancialSummary do
  let!(:user) { create(:user) }
  let!(:user2) { create(:user) }

  # Feel free to change what the subject-block returns
  subject(:cad) { FinancialSummary.new(user_id: user.id, currency: :cad) }
  subject(:cad2) { FinancialSummary.new(user_id: user2.id, currency: :cad) }
  subject(:subject2) { FinancialSummary.new(user_id: user2.id, currency: :usd) }
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

      create(:transaction, user: user2,
             action: :credit, category: :deposit,
             amount: Money.from_amount(1.12, :usd))

      create(:transaction, user: user2,
             action: :credit, category: :deposit,
             amount: Money.from_amount(9, :usd))

      create(:transaction, user: user2,
             action: :credit, category: :purchase,
             amount: Money.from_amount(6.67, :usd))

      create(:transaction, user: user2,
             action: :credit, category: :refund,
             amount: Money.from_amount(4, :cad))
    end

    expect(subject.one_day.user_id).to eq(user.id)
    expect(subject2.one_day.user_id).to eq(user2.id)
    expect(cad.one_day.user_id).to eq(user.id)
    expect(cad2.one_day.user_id).to eq(user2.id)

    expect(subject.one_day.currency).to eq(Money::Currency.wrap(:usd))
    expect(subject2.one_day.currency).to eq(Money::Currency.wrap(:usd))
    expect(cad.one_day.currency).to eq(Money::Currency.wrap(:cad))
    expect(cad2.one_day.currency).to eq(Money::Currency.wrap(:cad))

    expect(subject.one_day.after_at).to_not be_nil
    expect(subject2.one_day.after_at).to_not be_nil
    expect(cad.one_day.after_at).to_not be_nil
    expect(cad2.one_day.after_at).to_not be_nil

    expect(subject.one_day.count(:missing)).to eq(0)
    expect(subject.one_day.amount(:missing)).to eq(Money.from_amount(0.0, :usd))

    expect(subject.one_day.count(:deposit)).to eq(2)
    expect(subject.one_day.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))

    expect(subject.one_day.count(:purchase)).to eq(1)
    expect(subject.one_day.amount(:purchase)).to eq(Money.from_amount(7.67, :usd))

    expect(subject.one_day.count(:refund)).to eq(0)
    expect(subject.one_day.amount(:refund)).to eq(Money.from_amount(0, :usd))

    expect(cad.one_day.count(:refund)).to eq(1)
    expect(cad.one_day.amount(:refund)).to eq(Money.from_amount(5, :cad))

    expect(subject2.one_day.count(:deposit)).to eq(2)
    expect(subject2.one_day.amount(:deposit)).to eq(Money.from_amount(10.12, :usd))

    expect(subject2.one_day.count(:purchase)).to eq(1)
    expect(subject2.one_day.amount(:purchase)).to eq(Money.from_amount(6.67, :usd))

    expect(subject2.one_day.count(:refund)).to eq(0)
    expect(subject2.one_day.amount(:refund)).to eq(Money.from_amount(0, :usd))

    expect(cad2.one_day.count(:refund)).to eq(1)
    expect(cad2.one_day.amount(:refund)).to eq(Money.from_amount(4, :cad))
  end

  it 'summarizes over seven days' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12, :usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10, :usd))

      create(:transaction, user: user2,
             action: :credit, category: :deposit,
             amount: Money.from_amount(1.12, :usd))

      create(:transaction, user: user2,
             action: :credit, category: :deposit,
             amount: Money.from_amount(9, :usd))
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

      create(:transaction, user: user2,
             action: :credit, category: :purchase,
             amount: Money.from_amount(130, :usd))

      create(:transaction, user: user2,
             action: :credit, category: :purchase,
             amount: Money.from_amount(6.67, :usd))

      create(:transaction, user: user2,
             action: :credit, category: :refund,
             amount: Money.from_amount(4, :cad))
    end

    expect(subject.seven_days.user_id).to eq(user.id)
    expect(subject2.seven_days.user_id).to eq(user2.id)
    expect(cad.seven_days.user_id).to eq(user.id)
    expect(cad2.seven_days.user_id).to eq(user2.id)

    expect(subject.seven_days.currency).to eq(Money::Currency.wrap(:usd))
    expect(subject2.seven_days.currency).to eq(Money::Currency.wrap(:usd))
    expect(cad.seven_days.currency).to eq(Money::Currency.wrap(:cad))
    expect(cad2.seven_days.currency).to eq(Money::Currency.wrap(:cad))

    expect(subject.seven_days.after_at).to_not be_nil
    expect(subject2.seven_days.after_at).to_not be_nil
    expect(cad.seven_days.after_at).to_not be_nil
    expect(cad2.seven_days.after_at).to_not be_nil

    expect(subject.seven_days.count(:missing)).to eq(0)
    expect(subject.seven_days.amount(:missing)).to eq(Money.from_amount(0.0, :usd))

    expect(subject.seven_days.count(:deposit)).to eq(2)
    expect(subject.seven_days.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))

    expect(subject.seven_days.count(:purchase)).to eq(0)
    expect(subject.seven_days.amount(:purchase)).to eq(Money.from_amount(0, :usd))

    expect(subject.seven_days.count(:refund)).to eq(0)
    expect(subject.seven_days.amount(:refund)).to eq(Money.from_amount(0, :usd))

    expect(cad.seven_days.count(:refund)).to eq(0)
    expect(cad.seven_days.amount(:refund)).to eq(Money.from_amount(0, :cad))

    expect(subject2.seven_days.count(:deposit)).to eq(2)
    expect(subject2.seven_days.amount(:deposit)).to eq(Money.from_amount(10.12, :usd))

    expect(subject2.seven_days.count(:purchase)).to eq(0)
    expect(subject2.seven_days.amount(:purchase)).to eq(Money.from_amount(0, :usd))

    expect(subject2.seven_days.count(:refund)).to eq(0)
    expect(subject2.seven_days.amount(:refund)).to eq(Money.from_amount(0, :usd))

    expect(cad2.seven_days.count(:refund)).to eq(0)
    expect(cad2.seven_days.amount(:refund)).to eq(Money.from_amount(0, :cad))
  end

  it 'summarizes over lifetime' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12, :usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10, :usd))

      create(:transaction, user: user2,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12, :usd))

      create(:transaction, user: user2,
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

      create(:transaction, user: user2,
             action: :credit, category: :purchase,
             amount: Money.from_amount(130, :usd))

      create(:transaction, user: user2,
             action: :debit, category: :withdraw,
             amount: Money.from_amount(6.67, :usd))

      create(:transaction, user: user2,
             action: :credit, category: :refund,
             amount: Money.from_amount(4, :cad))

      create(:transaction, user: user2,
             action: :credit, category: :refund,
             amount: Money.from_amount(12.45, :usd))
    end

    expect(subject.lifetime.user_id).to eq(user.id)
    expect(subject2.lifetime.user_id).to eq(user2.id)
    expect(cad.lifetime.user_id).to eq(user.id)
    expect(cad2.lifetime.user_id).to eq(user2.id)

    expect(subject.lifetime.currency).to eq(Money::Currency.wrap(:usd))
    expect(subject2.lifetime.currency).to eq(Money::Currency.wrap(:usd))
    expect(cad.lifetime.currency).to eq(Money::Currency.wrap(:cad))
    expect(cad2.lifetime.currency).to eq(Money::Currency.wrap(:cad))

    expect(subject.lifetime.after_at).to be_nil
    expect(subject2.lifetime.after_at).to be_nil
    expect(cad.lifetime.after_at).to be_nil
    expect(cad2.lifetime.after_at).to be_nil

    expect(subject.lifetime.count(:missing)).to eq(0)
    expect(subject.lifetime.amount(:missing)).to eq(Money.from_amount(0.0, :usd))

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

    expect(subject2.lifetime.count(:deposit)).to eq(2)
    expect(subject2.lifetime.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))

    expect(subject2.lifetime.count(:purchase)).to eq(1)
    expect(subject2.lifetime.amount(:purchase)).to eq(Money.from_amount(130.00, :usd))

    expect(subject2.lifetime.count(:refund)).to eq(1)
    expect(subject2.lifetime.amount(:refund)).to eq(Money.from_amount(12.45, :usd))

    expect(cad2.lifetime.count(:refund)).to eq(1)
    expect(cad2.lifetime.amount(:refund)).to eq(Money.from_amount(4, :cad))

    expect(subject2.lifetime.count(:withdraw)).to eq(1)
    expect(subject2.lifetime.amount(:withdraw)).to eq(Money.from_amount(-6.67, :usd))
  end
end