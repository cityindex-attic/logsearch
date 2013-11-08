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
      'name:"Latency CIAPI.LogIn"'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_value
    res = eslog_simple_search(
      nil,
      'value:"10.11.12.13"'
    )

    assert_equal 2, res['hits']['total']
  end

  def test_latency_values_set_to_type_float
    res = eslog_simple_search(
      nil,
      '@message:"Latency CIAPI.*" OR "Latency General.*"'
    )

    assert_equal 1, res['hits']['total']
    assert_equal "2013-09-03T01:04:54.258Z", res['hits']['hits'][0]['_source']['@timestamp']
  end

  def test_non_latency_values_set_to_type_string
    res = eslog_simple_search(
      nil,
      'NOT @message:"Latency *"'
    )

    assert_equal 1, res['hits']['total']
  end
end
