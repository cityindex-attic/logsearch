require_relative 'common'
require "test/unit"

class SimpleNginxCombinedTest < Test::Unit::TestCase
  def test_respect_for_timestamp
    res = eslog_simple_search('logstash-2013.06.06')

    assert_equal 4, res['hits']['total']

    res = eslog_simple_search('logstash-2013.06.07')

    assert_equal 1, res['hits']['total']
  end

  def test_no_events_inferred_today
    assert_raise RuntimeError do
      eslog_simple_search("logstash-#{Time.new.strftime('%Y-%m-%d')}")
    end
  end

  def test_search_by_remote_addr
    res = eslog_simple_search(
      nil,
      '@fields.remote_addr:192.168.85.12'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_request_method
    res = eslog_simple_search(
      nil,
      '@fields.request_method:GET'
    )

    assert_equal 4, res['hits']['total']
  end

  def test_search_by_request_uri
    res = eslog_simple_search(
      nil,
      '@fields.request_uri:"/favicon.ico"'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_request_httpversion
    res = eslog_simple_search(
      nil,
      '@fields.request_httpversion:1.1'
    )

    assert_equal 5, res['hits']['total']
  end

  def test_search_by_status
    res = eslog_simple_search(
      nil,
      '@fields.status:302'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_body_bytes_sent
    res = eslog_simple_search(
      nil,
      '@fields.body_bytes_sent:976'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_body_bytes_sent_range
    res = eslog_search(
      '_search',
      {
        "filter" => {
          "range" => {
            "body_bytes_sent" => {
              "from" => 3000
            }
          }
        }
      }
    )

    assert_equal 2, res['hits']['total']
  end

  def test_search_by_http_referer
    res = eslog_simple_search(
      nil,
      '@fields.http_referer:"http://labs.cityindex.com/docs/"'
    )

    assert_equal 1, res['hits']['total']
  end

  def test_search_by_http_user_agent
    res = eslog_simple_search(
      nil,
      '@fields.http_user_agent:"\"Camo Asset Proxy 1.0.5\""'
    )

    assert_equal 1, res['hits']['total']
  end
end
