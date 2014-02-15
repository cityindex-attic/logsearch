This utilizes environment variables:

    export AWS_DEFAULT_REGION='' # region for aws calls
    export AWS_ACCESS_KEY_ID='' # aws credentials for stack updates
    export AWS_SECRET_ACCESS_KEY='' # aws credentials for stack updates

You can just use the `run.sh` script if you've installed the rest of the repository...

    ./bin/run --envname dev --servicename logsearch-dpb587-test1 \
        ElasticsearchDaytimeGroup GroupDesiredCapacity 2 daytime_elastic 2

Otherwise, you'll want to run `./bin/provision.sh` to ensure dependencies are installed.

If you need an external command to tunnel to the elasticsearch service, use `--tunnel` and `--tunnel-delay`

    ./bin/run --envname dev --servicename logsearch-dpb587-test1 \
        --tunnel "ssh -i id_rsa -N -T -L 9200:elasticsearch.srv-int.logsearch.cityindextest5.co.uk:9200 ubuntu@redis.live-logsearch.cityindextest5.co.uk" \
        --tunnel-delay 10 \
        ElasticsearchDaytimeGroup GroupDesiredCapacity 0 daytime_elastic 1

If you're into the containerization thing...

 > note/bug: for some reason, `resize.rb` seems to hang on a response while updating stack when running via docker

    cp ~/.ssh/id_rsa example/autoscale-simple/id_rsa # currently embeds the key in the container
    docker build -t logsearch/autoscale-simple example/autoscale-simple
    docker run -e AWS_DEFAULT_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e SSH_ID_RSA \
        logsearch/autoscale-simple \
        --envname dev --servicename logsearch-dpb587-test1 \
        --tunnel "echo \$SSH_ID_RSA > id_rsa ; chmod 600 id_rsa ; ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i id_rsa -N -T -L 9200:elasticsearch.srv-int.logsearch.cityindextest5.co.uk:9200 ubuntu@redis.live-logsearch.cityindextest5.co.uk" \
        --tunnel-delay 10 \
        ElasticsearchDaytimeGroup GroupDesiredCapacity 2 daytime_elastic 2
