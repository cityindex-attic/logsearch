require_relative 'common'
require 'minitest/autorun'

class CI_AppMetrics; end;

describe CI_AppMetrics, "type=ci_appmetrics" do

  it "should put events in the right index for their timestamp" do
    res = eslog_simple_search('logstash-2013.05.14')

    assert_equal 46, res['hits']['total']

    res = eslog_simple_search('logstash-2013.05.15')

    assert_equal 1, res['hits']['total']
  end

  it "should not infer any events for today" do
    assert_raises(RuntimeError) do
      eslog_simple_search("logstash-#{Time.new.strftime('%Y-%m-%d')}")
    end
  end

  it "should be possible to search by name" do
    res = eslog_simple_search(
      nil,
      'name:"Latency CIAPI.LogIn"'
    )

    assert_equal 1, res['hits']['total']
  end

  it "should be possible to search by value" do
    res = eslog_simple_search(
      nil,
      'value:"10.11.12.13"'
    )

    assert_equal 2, res['hits']['total']
  end

  it "should extract all numeric values into duration" do
    res = eslog_simple_search(
      nil,
      '_exists_:duration'
    )

    assert_equal 25, res['hits']['total']
    res['hits']['hits'][0]['_source']['duration'].must_be_instance_of Float
  end

end #describe
