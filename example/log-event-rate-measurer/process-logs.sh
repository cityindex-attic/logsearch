 #!/usr/bin/env bash
 
# this does `rm *`... make sure you're in the proper directory when running
for SERVICE in AccountInformationGateway AuthenticationGateway CiConnectGateway ClientPreferenceGateway HedgeGateway InstructionProcessorGateway MarketSearchGateway MessageGateway NewsGateway OrderGateway PriceHistoryGateway SimulationGateway TradingApi WatchlistGateway ; do
    rm -fr *

    for FILE in $(aws s3 list-objects --bucket=ci-logsearch --prefix="PPE-Logs/" | grep '"Key": "' | sed -r 's/.*: "([^"]+)",.*$/\1/' | grep $SERVICE/) ; do
        aws s3 get-object --bucket ci-logsearch --key "$FILE" `echo $FILE | openssl md5 | cut -c10-`.zip > /dev/null
    done

    unzip -qq -B '*.zip' 1>/dev/null 2>&1
    rm *.zip

    cat * | $1 | sed -r "s/(.*)/$SERVICE\t\1/"
done