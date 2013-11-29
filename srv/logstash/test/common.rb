require 'json'
require 'net/http'
require 'pty'
require 'tempfile'

def eslog_search(path, data)
  req = Net::HTTP::Post.new(path, { 'Content-Type' => 'application/json' })
  req.body = data.to_json

  res = Net::HTTP.new('localhost', '9200').start { |http| http.request(req) }

  raise "Query did not return successfully (status = #{res.code})" unless 200 == res.code.to_i

  res_data = JSON.parse(res.body)

  raise "Query timed out" unless false == res_data['timed_out']

  return res_data
end

def eslog_simple_search(index, query = '*:*')
  eslog_search(
    (index ? (index + '/') : '') + '_search',
    {
      "query" => {
        "filtered" => {
          "query" => {
            "query_string" => {
              "query" => query
            }
          }
        }
      }
    }
  )
end

def ensure_service_running(service_name)
  puts "  Ensuring #{service_name} is running..."
  unless /start\/running/ =~ `service #{service_name} status` 
    raise "service #{service_name} must be running.\nRun 'sudo start app' before running this test"
  end
end

def wait_for_file_to_contain(file, until_line)
  f = File.open(file,"r")
  f.seek(0,IO::SEEK_END)
  not_found = true
  while not_found do
    select([f])
    line = f.gets
    print "."
    if line =~ /.*#{Regexp.escape(until_line)}.*/
      puts " found #{until_line} in #{file}" 
      not_found = false
    end
    sleep 1
  end
end

def run_until(cmd, exit_regex, kill_delay = 0)
  unless File.exists?(cmd)
    cmd_file = Tempfile.new('run_until.sh')
    cmd_file.write("#!/usr/bin/env bash\n")
    cmd_file.write(cmd)
    cmd_file.close
    cmd = cmd_file.path
    File.chmod(0744, cmd)
  end
  is_shutting_down = false
  PTY.spawn( cmd ) do |stdout_and_err, stdin, pid| 
    begin
      stdout_and_err.each do |line| 
        print line 
        if (line =~ exit_regex && !is_shutting_down) 
          is_shutting_down = true
          puts "Shutting down process group #{pid} in #{kill_delay}s"
          sleep kill_delay
          Process.kill(-9, pid) # -9 == SIGTERM for whole process group
        end
      end
    rescue Errno::EIO
      #ignore - see http://stackoverflow.com/questions/10238298/ruby-on-linux-pty-goes-away-without-eof-raises-errnoeio     
    end
    Process.wait(pid)
  end
end #run_until