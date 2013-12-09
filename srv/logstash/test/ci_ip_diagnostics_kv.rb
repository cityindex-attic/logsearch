require_relative 'common'
require "test/unit"

class SimpleCiIPDiagnosticsTest < Test::Unit::TestCase
  def test_all_the_test_logs_were_imported
    res = eslog_simple_search('*')

    assert_equal 31, res['hits']['total']
  end

  def test_timestamps_are_parsed_correctly_from_DateTime
    res = eslog_simple_search(
      nil,
      'InstructionId:509490762'
    )

    assert_equal 1, res['hits']['total']

    assert_equal "2013-12-06T08:45:00.600Z", res['hits']['hits'][0]['_source']['@timestamp']
    assert_equal "2013-12-06T08:45:00.6009707+00:00", res['hits']['hits'][0]['_source']['DateTime']
  end

  def test_InstructionId
  	assert_field_matches "InstructionId:509490764", 4
  end

  def test_Level
  	assert_field_matches "Level:LEVEL2", 8
  end

  def test_ProcessDescRaw
  	assert_field_matches "ProcessDescRaw:(\"Fill/Accepted/Desk\")", 3
  end

  def test_ProcessDesc_Type
  	assert_field_matches "ProcessDesc.Type:\"New\"", 3
  end

  def test_ProcessDesc_Status
  	assert_field_matches "ProcessDesc.Status:\"Yellow Card\"", 3
  end

  def test_ProcessDesc_Source
  	assert_field_matches "ProcessDesc.Source:\"ITP\"", 4
  end

  def test_StartDateTime
  	assert_field_matches "StartDateTime:\"2013-12-06T08:55:36.0565963+00:00\"", 1
  end

  def test_TotalMs
  	assert_field_matches "TotalMs:1700.4218", 1
  end

  def test_TotalMs_is_float
  	assert_field_type "InstructionId:509490777", "TotalMs", Float
  end

  def test_Percentage
  	assert_field_matches "Percentage:15.54", 1
  end

  def test_Percentage_is_float
  	assert_field_type "Percentage:15.54", "Percentage", Float
  end

  def test_NoOfOrders
  	assert_field_matches "NoOfOrders:2", 4
  end

  def test_NoOfOrders_is_fixnum
  	assert_field_type "InstructionId:509490766", "NoOfOrders", Fixnum
  end

  def test_Value
  	assert_field_matches "Value:100", 10
  end

  def test_Value_is_float
  	assert_field_type "InstructionId:509490772", "Value", Float
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
