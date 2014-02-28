require_relative 'common'
require 'minitest/autorun'

class CIActiveMQStats; end;

describe CIActiveMQStats do

  it "should put events in the right index for their timestamp" do
    res = eslog_simple_search('logstash-2014.02.24')

    assert_equal 3, res['hits']['total']
  end

  it "should not infer any events for today" do
    assert_raises(RuntimeError) do
      eslog_simple_search("logstash-#{Time.new.strftime('%Y-%m-%d')}")
    end
  end

  it "should ignore header rows" do
    res = eslog_simple_search(
      nil,
      'ConnectionId:"ConnectionId"'
    ) 

    assert_equal 0, res['hits']['total']
  end

  it "should correctly parse out EnqueueCounter and DequeueCounter" do
    res = eslog_simple_search(
      nil,
      'ConnectionId:"ID:RDB-SRV-WEBL26-58703-1393147733882-0:31"'
    )

    assert_equal 1, res['hits']['total']

    res['hits']['hits'][0]['_source']['EnqueueCounter'].must_be_instance_of Fixnum
    assert_equal 306, res['hits']['hits'][0]['_source']['EnqueueCounter']
    
    res['hits']['hits'][0]['_source']['DequeueCounter'].must_be_instance_of Fixnum
    assert_equal 306, res['hits']['hits'][0]['_source']['DequeueCounter']

  end

end #describe
