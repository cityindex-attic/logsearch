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

  it "should convert lonlat comma separated string to array" do
    res = eslog_simple_search(
      nil,
      '_exists_:source_lonlat'
    )

    assert_equal 25, res['hits']['total']
    res['hits']['hits'][0]['_source']['source_lonlat'].must_be_instance_of Array
  end

end #describe
