#!/usr/bin/ruby
require 'test/unit'
require 'pry'
require File.join(File.dirname(__FILE__),'../lib/yahoo_finance')

class TestYahoo_finance_test < Test::Unit::TestCase
  def test_quotes
    quotes = YahooFinance.quotes(["BVSP", "AAPL"])
    assert_equal(2, quotes.size)
    
    assert_nothing_raised do
      q = YahooFinance.historical_quotes("MSFT", Time::now-(24*60*60*40), Time::now, { :raw => false, :period => :daily })
      [:trade_date, :open, :high, :low, :close, :volume, :adjusted_close].each do |col|
        assert q.first.send(col)
      end
    end

    assert_nothing_raised do
     q = YahooFinance.historical_quotes("MSFT", Time::now-(24*60*60*400), Time::now, { :raw => false, :period => :dividends_only })
     assert q.first.dividend_pay_date
     assert q.first.dividend_yield
    end
     
    assert_nothing_raised do
      YahooFinance.quotes(["AAPL", "MSFT", "BVSP", "JPYUSD" ],
                          YahooFinance::COLUMNS.take(20).collect { |k, v| v },
                          { raw: false })
    end
  end

  def test_escapes_symbol_for_url
    assert_nothing_raised do
      YahooFinance.quotes(["^AXJO"])
    end
    assert_nothing_raised do
      YahooFinance.historical_quotes("^AXJO", Time::now-(24*60*60*400), Time::now)
    end
  end
  
  def test_recognizes_csv_strings
    quotes = YahooFinance.quotes(["GOOG"], [:name])
    assert_no_match Regexp.new("^\""), quotes.first.name
  end

  def test_symbols
    symbols = YahooFinance.symbols("yahoo")
    assert_equal(10, symbols.size)

    assert_nothing_raised do
      symbols.first.symbol
      symbols.first.name
    end
  end
end
