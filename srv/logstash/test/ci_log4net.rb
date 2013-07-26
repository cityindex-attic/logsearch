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
      '@fields.level:ERROR'
    )

    assert_equal '2013-06-21T08:00:00.012Z', res['hits']['hits'][0]['_source']['@timestamp']
    assert_equal '2013-06-21 09:00:00,012', res['hits']['hits'][0]['_source']['@fields']['datetime'][0]
  end

  def test_no_events_inferred_today
    assert_raise RuntimeError do
      eslog_simple_search("logstash-#{Time.new.strftime('%Y-%m-%d')}")
    end
  end

  def test_search_by_level
    res = eslog_simple_search(
      nil,
      '@fields.level:INFO'
    )

    assert_equal 1, res['hits']['total']

    res = eslog_simple_search(
      nil,
      '@fields.level:ERROR'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_thread
    res = eslog_simple_search(
      nil,
      '@fields.thread:Margin_4'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_logger
    res = eslog_simple_search(
      nil,
      '@fields.logger:MarginCalculation'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_message
    res = eslog_simple_search(
      nil,
      '@fields.message:"MCATP:False"'
    )

    assert_equal 1, res['hits']['total']
  end
end
