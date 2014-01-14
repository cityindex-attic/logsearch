require_relative 'common'
require "test/unit"

class SimpleCiIPDiagnosticsTest < Test::Unit::TestCase
  def test_timestamps_are_parsed_correctly_from_arrival_time_tz
    res = eslog_simple_search(
      nil,
      'instruction_id:502625247'
    )

    assert_equal 1, res['hits']['total']

    assert_equal "2013-09-03T01:04:54.258+00:00", res['hits']['hits'][0]['_source']['@timestamp']
    assert_equal "2013-09-03T02:04:54.258+01:00", res['hits']['hits'][0]['_source']['arrival_time_tz']
  end

  def test_instruction_id
  	assert_field_matches "instruction_id:502625247", 1
  end

  def test_level
  	assert_field_matches "level:\"LEVEL1\"", 26
  end

  def test_instruction_description
  	assert_field_matches "instruction_description:(\"New/Yellow Card/ITP\")", 3
  end

  def test_instruction_type
  	assert_field_matches "instruction.type:\"New\"", 26
  end

  def test_instruction_source
  	assert_field_matches "instruction.source:\"ITP\"", 26
  end

  def test_instruction_status
  	assert_field_matches "instruction.status:\"Yellow Card\"", 3
  end

  def test_arrival_time
  	assert_field_matches "arrival_time:\"00:56:22.591\"", 1
  end

  def test_duration_ms
  	assert_field_matches "duration_ms:17114.4067", 1
  end

  def test_duration_ms_is_float
  	assert_field_type "instruction_id:502625247", "duration_ms", Float
  end

  def test_percentage_of_total
  	assert_field_matches "percentage_of_total:0.18", 1
  end

  def test_percentage_of_total_is_float
  	assert_field_type "instruction_id:502625247", "percentage_of_total", Float
  end

  def test_quotes_orders_affected
  	assert_field_matches "quotes_orders_affected:2", 9
  end

  def test_quotes_orders_affected_is_fixnum
  	assert_field_type "instruction_id:502625247", "quotes_orders_affected", Fixnum
  end

  def assert_field_matches(field_query, expected_matches)
    actual = eslog_simple_search(
      nil,
      "#{field_query}"
    )

    assert_equal expected_matches, actual['hits']['total'], 
      "Searching for #{field_query} identified the wrong number of requests: #{JSON.pretty_generate(actual)}"
  end

  def assert_field_type(field_query, field, type)
    res = eslog_simple_search(
      nil,
      "#{field_query}"
    )
    value = res['hits']['hits'][0]['_source'][field]

    assert_equal type, value.class, "field is: #{value} \n===========Full query result============= #{JSON.pretty_generate(res)}"
  end


end
