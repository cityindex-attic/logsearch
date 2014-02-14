#!/usr/bin/env ruby

require 'dotenv'
require 'json'
require 'net/http'
require 'tempfile'
require 'shellwords'
require 'date'

# args: resource parameter newsize esattrval replication

# setup

@elasticsearch = Net::HTTP.new 'localhost', 9200

def putlog(msg)
  puts "#{DateTime.now.new_offset(0).strftime('%FT%TZ')}#{msg}"
end

def update_replication_requirements()
  putlog ' + updating replication requirements...'

  @elasticsearch.start do | http |
    req = Net::HTTP::Put.new(
      '/_settings',
      initheader = { 'Accept' => 'application/json' }
    )
    req.body = JSON.generate({
      'index' => {
        'number_of_replicas' => ARGV[4],
      },
    })

    http.request req
  end

  putlog ' - updated replication requirements'
end


#export APP_ENVIRONMENT_NAME=dev ; export APP_SERVICE_NAME=logsearch-dpb587-test1

# ready, set, go...

# describe cfn
# double check scaling arguments with the cloudformation stack

putlog ' + validating cloudformation references...'

cfn_root_stack_name = "#{ENV['APP_ENVIRONMENT_NAME']}-#{ENV['APP_SERVICE_NAME']}"

rootstack = JSON.parse(`aws cloudformation describe-stacks --stack-name #{cfn_root_stack_name.shellescape}`)
putlog " > RootStack: #{rootstack['Stacks'][0]['StackName']} (#{rootstack['Stacks'][0]['CreationTime']})"

resource = JSON.parse(`aws cloudformation describe-stack-resource --stack-name #{cfn_root_stack_name.shellescape} --logical-resource-id #{ARGV[0].shellescape}`)
putlog " > Target: #{resource['StackResourceDetail']['PhysicalResourceId']}"

substacktemplate = JSON.parse(`aws cloudformation get-template --stack-name #{resource['StackResourceDetail']['PhysicalResourceId'].shellescape}`)['TemplateBody']
substack = JSON.parse(`aws cloudformation describe-stacks --stack-name #{resource['StackResourceDetail']['PhysicalResourceId'].shellescape}`)

stackparam = nil

substack['Stacks'][0]['Parameters'].each do | parameter |
  if ARGV[1] == parameter['ParameterKey'] then
    stackparam = parameter
  end
end

if nil == stackparam then
  raise "Unable to find #{ARGV[1]} parameter"
end

putlog " > #{stackparam['ParameterKey']}: #{stackparam['ParameterValue']}"

putlog ' - validated cloudformation references'


# todo
# figure out what needs to be done

if ARGV[2] == stackparam['ParameterValue'] then
  putlog ' = seems like nothing needs to be done'

  exit
elsif ARGV[2] > stackparam['ParameterValue'] then
  putlog ' = we will be scaling up'
else
  putlog ' = we will be scaling down'
end

adjusting_nodes_count = ARGV[2].to_i - stackparam['ParameterValue'].to_i


# node discovery
# we should figure out which nodes are going down

req_nodes = @elasticsearch.start do | http |
  http.get "/_cluster/nodes", { 'Content-Type' => 'application/json' }
end

nodes = JSON.parse(req_nodes.body)

significant_nodes = {}
significant_nodes_count = 0

putlog ' + discovering nodes...'

nodes['nodes'].each do | id, node |
  if node['attributes'].has_key? 'logsearch' then
    if not significant_nodes.has_key? node['attributes']['logsearch'] then
      significant_nodes[node['attributes']['logsearch']] = {}
    end

    ip = node['transport_address'].gsub(/inet\[\/([^:]+):\d+\]/, '\1')

    significant_nodes[node['attributes']['logsearch']][id] = node
    significant_nodes_count += 1

    if ARGV[3] == node['attributes']['logsearch'] then
      putlog " > node #{id} (#{ip}) will be terminated"
    else
      putlog " > node #{id} (#{ip}) is active"
    end
  end
end

putlog ' - discovered nodes'

original_nodes_count = significant_nodes_count


# relocate shards
# @todo? to be safe, manually move primary shards off elastic nodes

if adjusting_nodes_count < 0 then
  putlog ' + reviewing allocations...'

  req_state = @elasticsearch.start do | http |
    http.get '/_cluster/state?filter_nodes&filter_metadata&filter_blocks&filter_indices', { 'Content-Type' => 'application/json' }
  end

  state = JSON.parse(req_state.body)

  if significant_nodes.has_key? ARGV[3] then
    significant_nodes[ARGV[3]].each do | id, node |
      state['routing_nodes']['nodes'][id].each do | shard |
        if shard['primary'] then
          putlog " > node #{id} has a primary shard: index '#{shard[index]}', shard '#{shard}', replica '#{replicaidx}'"
        end
      end
    end
  end

  putlog ' - reviewed allocations'
end


# disable allocations
# prevent node scaling from thrashing disks

putlog ' + disabling allocations...'

@elasticsearch.start do | http |
  http.post '/_cluster/settings', JSON.generate({
      'transient' => {
        'cluster.routing.allocation.disable_allocation' => true,
      },
    }), { 'Accept' => 'application/json' }
end

putlog ' - disabled allocations'


# replication
# increase it if we're scaling up

if 0 < adjusting_nodes_count then
  update_replication_requirements
end


# update stack
# reduce our auto-scaling groups

putlog ' + updating stack...'

newparams = []

substack['Stacks'][0]['Parameters'].each do | parameter |
  if ARGV[1] == parameter['ParameterKey'] then
    parameter['ParameterValue'] = ARGV[2]
  end

  newparams.push(parameter)
end

cfntpl = Tempfile.new('cfntpl')
cfntpl.write(JSON.generate(substacktemplate))

cmd = 'aws cloudformation update-stack'
cmd += " --stack-name #{substack['Stacks'][0]['StackName']}"
cmd += " --template-body file://#{cfntpl.path.shellescape}"
cmd += " --parameters '#{JSON.generate(newparams)}'"

if 0 != adjusting_nodes_count then
  result = JSON.generate(JSON.parse(`#{cmd}`))
  putlog " > #{result}"
end

cfntpl.unlink

putlog ' - updated stack'


# wait
# watch for node changes

putlog ' + nodes are not yet ready...'

while true do
  sleep 10

  req_nodes = @elasticsearch.start do | http |
    http.get '/_cluster/nodes', { 'Content-Type' => 'application/json' }
  end

  nodes = JSON.parse(req_nodes.body)

  # look for new nodes
  nodes['nodes'].each do | id, node |
    if node['attributes'].has_key? 'logsearch' then
      if not significant_nodes.has_key? node['attributes']['logsearch'] then
        significant_nodes[node['attributes']['logsearch']] = {}
      end

      if not significant_nodes[node['attributes']['logsearch']].has_key? id then
        ip = node['transport_address'].gsub(/inet\[\/([^:]+):\d+\]/, '\1')

        putlog " > node #{id} (#{ip}) joined the cluster"

        significant_nodes[node['attributes']['logsearch']][id] = node
        significant_nodes_count += 1
      end
    end
  end

  # look for dropped nodes
  significant_nodes.each do | attr, attrnodes |
    attrnodes.each do | id, node |
      if not nodes['nodes'].has_key? id then
        ip = node['transport_address'].gsub(/inet\[\/([^:]+):\d+\]/, '\1')
        putlog " > node #{id} (#{ip}) left the cluster"

        significant_nodes[attr].delete(id)
        significant_nodes_count -= 1
      end
    end
  end

  if significant_nodes_count == original_nodes_count + adjusting_nodes_count then
    break
  end
end

putlog ' - nodes are ready'


# replication
# decrease it if we're scaling down

if 0 > adjusting_nodes_count then
  update_replication_requirements
end


# enable allocations
# nodes are up, so let them rebalance

putlog ' + enabling allocations...'

@elasticsearch.start do | http |
  http.post '/_cluster/settings', JSON.generate({
      'transient' => {
        'cluster.routing.allocation.disable_allocation' => false,
      },
    }), { 'Accept' => 'application/json' }
end

putlog ' - enabled allocations'


# stability
# to be safe, make sure we're back to green

putlog " + cluster is not yet 'green'..."

while true do
  sleep 10

  found = false

  req_health = @elasticsearch.start do | http |
    http.get '/_cluster/health', { 'Content-Type' => 'application/json' }
  end

  health = JSON.parse(req_health.body)

  if 'green' == health['status'] then
    break
  end
end

putlog " - cluster is 'green'"
