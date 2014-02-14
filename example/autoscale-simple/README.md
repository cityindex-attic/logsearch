This utilizes environment variables:

    export AWS_DEFAULT_REGION='' # region for aws calls
    export AWS_ACCESS_KEY_ID='' # aws credentials for stack updates
    export AWS_SECRET_ACCESS_KEY='' # aws credentials for stack updates
    export APP_ENVIRONMENT_NAME='live' # name for stackformation discovery
    export APP_SERVICE_NAME='logsearch' # name for stackformation discovery

You can just use the `run.sh` script if you've installed the rest of the repository...

    ./bin/run.sh \
        - ElasticsearchDaytimeGroup GroupDesiredCapacity 2 daytime_elastic 2

Otherwise, you'll want to run `./bin/provision.sh` to ensure dependencies are installed.

If you need to tunnel to the elasticsearch service, provide a command to run as the first argument instead of `-`...

    ./bin/run.sh \
        "ssh -i id_rsa -N -T -L 9200:elasticsearch.srv-int.logsearch.cityindextest5.co.uk:9200 ubuntu@redis.live-logsearch.cityindextest5.co.uk" \
        ElasticsearchDaytimeGroup GroupDesiredCapacity 2 daytime_elastic 2

If you're into the containerization thing...

 > note/bug: for some reason, `resize.rb` seems to hang on a response while updating stack when running via docker

    cp ~/.ssh/id_rsa example/autoscale-simple/id_rsa # currently embeds the key in the container
    sudo docker build -t logsearch/autoscale-simple example/autoscale-simple
    sudo -E docker run -e AWS_DEFAULT_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e APP_ENVIRONMENT_NAME -e APP_SERVICE_NAME \
        logsearch/autoscale-simple \
        "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i id_rsa -N -T -L 9200:elasticsearch.srv-int.logsearch.cityindextest5.co.uk:9200 ubuntu@redis.live-logsearch.cityindextest5.co.uk" \
        ElasticsearchDaytimeGroup GroupDesiredCapacity 2 daytime_elastic 2
