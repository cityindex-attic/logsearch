require_relative 'common'
require "test/unit"

class SimpleIisDefaultTest < Test::Unit::TestCase
  def test_respect_for_timestamp
    res = eslog_simple_search('logstash-2013.06.05')

    assert_equal 41, res['hits']['total']

    res = eslog_simple_search('logstash-2013.06.06')

    assert_equal 7, res['hits']['total']
  end

  def test_no_events_inferred_today
    assert_raise RuntimeError do
      eslog_simple_search("logstash-#{Time.new.strftime('%Y-%m-%d')}")
    end
  end

  def test_search_by_s_sitename
    res = eslog_simple_search(
      nil,
      's_sitename:W3SVC1'
    )

    assert_equal 48, res['hits']['total']
  end

  def test_search_by_s_computername
    res = eslog_simple_search(
      nil,
      's_computername:"PKH-PPE-WEB24"'
    )

    assert_equal 48, res['hits']['total']
  end

  def test_search_by_s_ip
    res = eslog_simple_search(
      nil,
      's_ip:172.16.68.6'
    )

    assert_equal 4, res['hits']['total']
  end

  def test_search_by_cs_method
    res = eslog_simple_search(
      nil,
      'cs_method:POST'
    )

    assert_equal 8, res['hits']['total']
  end

  def test_search_by_cs_uri_stem
    res = eslog_simple_search(
      nil,
      'cs_uri_stem:"/TradingAPI/Scripts/tradingApi.js"'
    )

    assert_equal 14, res['hits']['total']
  end

  def test_search_by_cs_uri_query
    res = eslog_simple_search(
      nil,
      'cs_uri_query:"interval=MINUTE&span=1&PriceBars=20"'
    )

    assert_equal 2, res['hits']['total']
  end

  def test_search_by_s_port
    res = eslog_simple_search(
      nil,
      's_port:445'
    )

    assert_equal 2, res['hits']['total']
  end

  def test_search_by_c_ip
    res = eslog_simple_search(
      nil,
      'c_ip:172.16.68.245'
    )

    assert_equal 48, res['hits']['total']
  end

  def test_search_by_cs_version
    res = eslog_simple_search(
      nil,
      'cs_version:1.1'
    )

    assert_equal 48, res['hits']['total']
  end

  def test_search_by_cs_user_agent
    res = eslog_simple_search(
      nil,
      'cs_user_agent:"CIAPI.CS.10.0.0.548"'
    )

    assert_equal 24, res['hits']['total']
  end

  def test_search_by_cs_host
    res = eslog_simple_search(
      nil,
      'cs_host:"ciapipreprod.cityindextest8.co.uk"'
    )

    assert_equal 2, res['hits']['total']
  end

  def test_search_by_sc_status
    res = eslog_simple_search(
      nil,
      'sc_status:304'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_sc_substatus
    res = eslog_simple_search(
      nil,
      'sc_substatus:0'
    )

    assert_equal 48, res['hits']['total']
  end

  def test_search_by_win32_status
    res = eslog_simple_search(
      nil,
      'win32_status:0'
    )

    assert_equal 48, res['hits']['total']
  end

  def test_search_by_sc_bytes
    res = eslog_simple_search(
      nil,
      'sc_bytes:469'
    )

    assert_equal 4, res['hits']['total']
  end

  def test_search_by_cs_bytes
    res = eslog_simple_search(
      nil,
      'cs_bytes:320'
    )

    assert_equal 2, res['hits']['total']
  end

  def test_search_by_time_taken
    res = eslog_simple_search(
      nil,
      'time_taken:296'
    )

    assert_equal 1, res['hits']['total']
  end
end
