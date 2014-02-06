require_relative 'common'
require "test/unit"

class SimpleCiLog4netTest < Test::Unit::TestCase
  def test_respect_for_timestamp
    res = eslog_simple_search('logstash-2013.06.20')

    assert_equal 1, res['hits']['total']

    res = eslog_simple_search('logstash-2013.06.21')

    assert_equal 1, res['hits']['total']
  end

  def test_timestamps_are_converted_from_localtime_to_utc
    res = eslog_simple_search(
      nil,
      'level:ERROR'
    )

    assert_equal '2013-06-21T08:00:00.012+00:00', res['hits']['hits'][0]['_source']['@timestamp']
    assert_equal '2013-06-21 09:00:00,012', res['hits']['hits'][0]['_source']['datetime']
  end

  def test_no_events_inferred_today
    assert_raise RuntimeError do
      eslog_simple_search("logstash-#{Time.new.strftime('%Y-%m-%d')}")
    end
  end

  def test_search_by_level
    res = eslog_simple_search(
      nil,
      'level:INFO'
    )

    assert_equal 1, res['hits']['total']

    res = eslog_simple_search(
      nil,
      'level:ERROR'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_thread
    res = eslog_simple_search(
      nil,
      'thread:Margin_4'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_logger
    res = eslog_simple_search(
      nil,
      'logger:MarginCalculation'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_message
    res = eslog_simple_search(
      nil,
      'message:"Order: 483553318 filtered"'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_message1
    res = eslog_simple_search(
      nil,
      'message:"MCATP:False"'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_message_newline
    res = eslog_simple_search(
      nil,
      'message:"MC - CA:400220534 MI:15.181891073288527743228387400\\\\r\\\\n  Ind:False MCP:True MCATP:False"'
    )

    assert_equal 1, res['hits']['total']
  end
end
