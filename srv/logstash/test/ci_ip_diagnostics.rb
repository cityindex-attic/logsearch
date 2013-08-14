require_relative 'common'
require "test/unit"

class SimpleCiIPDiagnosticsTest < Test::Unit::TestCase
  def test_all_the_test_logs_were_imported
    res = eslog_simple_search('*')

    assert_equal 32, res['hits']['total']
  end
end