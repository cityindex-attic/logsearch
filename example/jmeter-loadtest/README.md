This is a rudimentary script which will take an indexed elasticsearch request log and generate
a jmeter test plan. By specifying multiple users, it creates multiple thread groups and distributes
requests into them. By specifying user clones, those thread groups will have multiple threads.

If you're forwarding the elasticsearch request log into logstash/kibana, you should be able to just
pipe the `curl` command the inspection window provides into something like:

    ./generate.rb --target logsearch.example.com --virtual-users 60 --max-request-rate 500 > jmeter-test1.jmx
