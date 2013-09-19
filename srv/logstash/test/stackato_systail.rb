require_relative 'common'
require "test/unit"

class SimpleStackatoSystailTest < Test::Unit::TestCase
  def test_respect_for_timestamp
    res = eslog_simple_search('logstash-2013.06.09')

    assert_equal 1, res['hits']['total']

    res = eslog_simple_search('logstash-2013.06.10')

    assert_equal 17, res['hits']['total']
  end

  def test_no_events_inferred_today
    assert_raise RuntimeError do
      eslog_simple_search("logstash-#{Time.new.strftime('%Y-%m-%d')}")
    end
  end

  def test_search_by_Name
    res = eslog_simple_search(
      nil,
      'Name:cloud_controller'
    )

    assert_equal 5, res['hits']['total']
  end

  def test_search_by_NodeID
    res = eslog_simple_search(
      nil,
      'NodeID:"10.11.12.14"'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_Text
    res = eslog_simple_search(
      nil,
      'Text:"Jun 10 15:17:01 apps su[12223]: + ??? root:stackato"'
    )

    assert_equal 1, res['hits']['total']
  end
end
