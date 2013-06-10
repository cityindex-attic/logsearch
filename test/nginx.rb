require_relative 'common'
require "test/unit"

class SimpleNginxTest < Test::Unit::TestCase
  def test_respect_for_timestamp
    res = eslog_search(
      'logstash-2013.06.06/_search',
      {
        "query" => {
          "filtered" => {
            "query" => {
              "query_string" => {
                "query" => "*"
              }
            }
          }
        }
      }
    )

    assert_equal 4, res['hits']['total']

    res = eslog_search(
      'logstash-2013.06.07/_search',
      {
        "query" => {
          "filtered" => {
            "query" => {
              "query_string" => {
                "query" => "*"
              }
            }
          }
        }
      }
    )

    assert_equal 1, res['hits']['total']
  end

  def test_no_events_inferred_today
    assert_raise RuntimeError do
      eslog_search(
        "logstash-#{Time.new.strftime('%Y-%m-%d')}/_search",
        {
          "query" => {
            "filtered" => {
              "query" => {
                "query_string" => {
                  "query" => "*"
                }
              }
            }
          }
        }
      )
    end
  end
end
