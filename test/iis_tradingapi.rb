require_relative 'common'
require "test/unit"

# Requests in the IIS logs should be tagged to make matching up with the names in the documentation easy 
# http://labs.cityindex.com/docs/  > Contents > CIAPI Reference > HTTP Services > Group > Service
# i.e:  2013-06-05 00:00:34 W3SVC1 PKH-PPE-WEB24 172.16.68.7 POST /TradingApi/session - 444 - 172.16.68.245 HTTP/1.1 CIAPI.CS.10.0.0.548 - - ciapipreprod.cityindextest9.co.uk 200 0 0 590 422 281
# should be tagged:  servicegroup=Authentication, servicename=LogOn
class SimpleTradingAPITest < Test::Unit::TestCase
  def test_search_for_LogOn
    expected = eslog_simple_search(
      nil,
      '@fields.cs_method=POST AND @fields.cs_uri_stem=TradingApi\/session'
    )
    assert_block "The sample data doesn't contain any LogOn requests" do
      expected['hits']['total'] > 0 
    end

    actual = eslog_simple_search(
      nil,
      '@fields.servicename=LogOn'
    )

    assert_equal expected['hits']['total'], actual['hits']['total'], "Searching by servicename=LogOn didn't identify all the requests"
  end
end