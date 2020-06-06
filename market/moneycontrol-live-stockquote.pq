let
    Source01 = Json.Document(Web.Contents("https://priceapi-aws.moneycontrol.com/pricefeed/nse/equitycash/RI")),
    Source02 = Json.Document(Web.Contents("https://priceapi-aws.moneycontrol.com/pricefeed/nse/equitycash/IT")),
    data = Table.FromRecords({
        [Security = Source01[data][SC_FULLNM], Price = Source01[data][pricecurrent]],
        [Security = Source02[data][SC_FULLNM], Price = Source02[data][pricecurrent]]
    })
in
    data