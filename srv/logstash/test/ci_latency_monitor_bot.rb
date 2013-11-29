require_relative 'common'
require 'minitest/autorun'

class CILatencyMonitorBot; end;

describe CILatencyMonitorBot, "type=ci_latency_monitor_bot" do

  it "should put events in the right index for their timestamp" do
    res = eslog_simple_search('logstash-2013.11.26')

    assert_equal 6, res['hits']['total']

  end

  it "should not infer any events for today" do
    assert_raises(RuntimeError) do
      eslog_simple_search("logstash-#{Time.new.strftime('%Y-%m-%d')}")
    end
  end

  it "should convert treat @source.lonlat as an array" do
    res = eslog_simple_search(
      nil,
      '_exists_:@source.lonlat'
    )

    assert_equal 6, res['hits']['total']
    res['hits']['hits'][0]['_source']['@source.lonlat'].must_be_instance_of Array
  end

   it "should treat 'Latency General.StaticPage' as a float" do
    res = eslog_simple_search(
      nil,
      '_exists_:"Latency General.StaticPage"'
    )

    assert_equal 2, res['hits']['total']
    res['hits']['hits'][0]['_source']['Latency General.StaticPage'].must_be_instance_of Float
  end

end #describe
