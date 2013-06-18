require_relative 'common'
require "test/unit"

# Requests in the IIS logs should be tagged to make matching up with the names in the documentation easy 
# http://labs.cityindex.com/docs/  > Contents > CIAPI Reference > HTTP Services > Group > Service
# i.e:  2013-06-05 00:00:34 W3SVC1 PKH-PPE-WEB24 172.16.68.7 POST /TradingApi/session - 444 - 172.16.68.245 HTTP/1.1 CIAPI.CS.10.0.0.548 - - ciapipreprod.cityindextest9.co.uk 200 0 0 590 422 281
# should be tagged:  servicegroup=Authentication, servicename=LogOn
class SimpleTradingAPITest < Test::Unit::TestCase
  def test_respect_for_timestamp
    res = eslog_simple_search('logstash-2013.06.05')

    assert_equal 41, res['hits']['total']

    res = eslog_simple_search('logstash-2013.06.06')

    assert_equal 7, res['hits']['total']
  end

  def test_timetaken_should_be_integer
    res = eslog_simple_search(
      nil,
      "@fields.ci_tradingapi_servicename:LogOn"
    )
    actual_time_taken = res['hits']['hits'][0]['_source']['@fields']['time_taken'][0]

    assert_equal Fixnum, actual_time_taken.class, "actual_time_taken is: #{actual_time_taken}"
  end

  def test_search_for_LogOn
   assert_servicename "LogOn", 2
  end
  def test_search_for_DeleteSession
   assert_servicename "DeleteSession", 2
  end
  def test_search_for_ListTradeHistory
   assert_servicename "ListTradeHistory", 2
  end
  def test_search_for_ListSpreadMarkets
   assert_servicename "ListSpreadMarkets", 2
  end
  def test_search_for_ListOpenPositions
   assert_servicename "ListOpenPositions", 4
  end
  def test_search_for_ListNewsHeadlinesWithSource
   assert_servicename "ListNewsHeadlinesWithSource", 2
  end
  def test_search_for_GetPriceBars
   assert_servicename "GetPriceBars", 2
  end
  def test_search_for_GetMarketInformation
    assert_servicename "GetMarketInformation", 2
  end
  def test_search_for_GetClientAndTradingAccount
    assert_servicename "GetClientAndTradingAccount", 2
  end
  def test_search_for_Trade
    assert_servicename "Trade", 4
  end

  def assert_servicename(servicename, expected_matches)
    actual = eslog_simple_search(
      nil,
      "@fields.ci_tradingapi_servicename:#{servicename}"
    )

    assert_equal expected_matches, actual['hits']['total'], 
      "Searching for @fields.ci_tradingapi_servicename:#{servicename} identified the wrong number of requests: #{JSON.pretty_generate(actual)}"
  end
end