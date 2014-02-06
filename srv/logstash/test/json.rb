require_relative 'common'
require "test/unit"

class SimpleJsonDefaultTest < Test::Unit::TestCase
  def test_respect_for_timestamp
    res = eslog_simple_search('logstash-2014.02.04')

    assert_equal 1, res['hits']['total']

    res = eslog_simple_search('logstash-2014.02.05')

    assert_equal 1, res['hits']['total']
  end

  def test_message_string
    res = eslog_simple_search(
      nil,
      'message:"plain message accepted here."'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_message_string_partial
    res = eslog_simple_search(
      nil,
      'message:"message"'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_message_obj_message
    res = eslog_simple_search(
      nil,
      'message_obj.Message:"Quote has been accepted."'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_message_obj_message_partial
    res = eslog_simple_search(
      nil,
      'message_obj.Message:"accepted"'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_arbitrary_logger
    res = eslog_simple_search(
      nil,
      'logger:"I.am.a.JSON.logger"'
    )

    assert_equal 2, res['hits']['total']
  end
end
