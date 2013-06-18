require_relative 'common'
require "test/unit"

class SimpleCiAppmetricsTest < Test::Unit::TestCase
  def test_respect_for_timestamp
    res = eslog_simple_search('logstash-2013.05.14')

    assert_equal 44, res['hits']['total']

    res = eslog_simple_search('logstash-2013.05.15')

    assert_equal 1, res['hits']['total']
  end

  def test_no_events_inferred_today
    assert_raise RuntimeError do
      eslog_simple_search("logstash-#{Time.new.strftime('%Y-%m-%d')}")
    end
  end

  def test_search_by_name
    res = eslog_simple_search(
      nil,
      '@fields.name:"Latency CIAPI.LogIn"'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_value
    res = eslog_simple_search(
      nil,
      '@fields.value:"10.11.12.13"'
    )

    assert_equal 2, res['hits']['total']
  end
end
