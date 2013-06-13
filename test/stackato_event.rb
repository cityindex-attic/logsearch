require_relative 'common'
require "test/unit"

class SimpleStackatoEventTest < Test::Unit::TestCase
  def test_respect_for_timestamp
    res = eslog_simple_search('logstash-2013.06.09')

    assert_equal 1, res['hits']['total']

    res = eslog_simple_search('logstash-2013.06.10')

    assert_equal 10, res['hits']['total']
  end

  def test_no_events_inferred_today
    assert_raise RuntimeError do
      eslog_simple_search("logstash-#{Time.new.strftime('%Y-%m-%d')}")
    end
  end

  def test_search_by_Type
    res = eslog_simple_search(
      nil,
      '@fields.Type=kato_action'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_Desc
    res = eslog_simple_search(
      nil,
      '@fields.Desc=httpbin'
    )

    assert_equal 2, res['hits']['total']
  end

  def test_search_by_Severity
    res = eslog_simple_search(
      nil,
      '@fields.Severity=ERROR'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_Info
    res = eslog_simple_search(
      nil,
      '@fields.Info.app_name=httpbin'
    )

    assert_equal 2, res['hits']['total']
  end

  def test_search_by_Process
    res = eslog_simple_search(
      nil,
      '@fields.Process=supervisord'
    )

    assert_equal 5, res['hits']['total']
  end

  def test_search_by_NodeID
    res = eslog_simple_search(
      nil,
      '@fields.NodeID="10.11.12.14"'
    )

    assert_equal 1, res['hits']['total']
  end
end
