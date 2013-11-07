require_relative 'common'
require "test/unit"

class SimpleStackatoApptailTest < Test::Unit::TestCase
  def test_respect_for_timestamp
    res = eslog_simple_search('logstash-2013.06.09')

    assert_equal 1, res['hits']['total']

    res = eslog_simple_search('logstash-2013.06.10')

    assert_equal 3, res['hits']['total']
  end

  def test_no_events_inferred_today
    assert_raise RuntimeError do
      eslog_simple_search("logstash-#{Time.new.strftime('%Y-%m-%d')}")
    end
  end

  def test_search_by_Text
    res = eslog_simple_search(
      nil,
      'Text:"Jun 10, 2013 3:08:24 PM hudson.model.AsyncPeriodicWork$1 run"'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_LogFilename
    res = eslog_simple_search(
      nil,
      'LogFilename:stdout.log'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_AppID
    res = eslog_simple_search(
      nil,
      'AppID:172'
    )

    assert_equal 2, res['hits']['total']
  end

  def test_search_by_AppName
    res = eslog_simple_search(
      nil,
      'AppName:httpbin'
    )

    assert_equal 2, res['hits']['total']
  end

  def test_search_by_InstanceIndex
    res = eslog_simple_search(
      nil,
      'InstanceIndex:0'
    )

    assert_equal 4, res['hits']['total']
  end

  def test_search_by_NodeID
    res = eslog_simple_search(
      nil,
      'NodeID:10.11.12.13'
    )

    assert_equal 4, res['hits']['total']
  end

  def test_search_by_Source
    res = eslog_simple_search(
      nil,
      'Source:app'
    )

    assert_equal 4, res['hits']['total']
  end
end
