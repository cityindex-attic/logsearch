require_relative 'common'
require 'minitest/autorun'

class CFLoggregatorSyslog; end;

describe CFLoggregatorSyslog, "type=cf_loggregator_syslog" do

  it "should put events in the right index for their timestamp" do
    res = eslog_simple_search('logstash-2013-12-01')

    assert_equal 6, res['hits']['total']

  end

  it "should not infer any events for today" do
    assert_raises(RuntimeError) do
      eslog_simple_search("logstash-#{Time.new.strftime('%Y-%m-%d')}")
    end
  end

  it "should extract the loggregator component" do
    res = eslog_simple_search(
      nil,
      '@loggregator.component:App'
    )

    assert_equal 1, res['hits']['total']
    assert_equal "App", res['hits']['hits'][0]['_source']['@loggregator.component']
  end

end #describe
